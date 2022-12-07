//
//  FavoritesService.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/12/05.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import SQLite3
import RxSwift
import RxRelay
import RxCocoa

fileprivate let defaultDatabaseName = "favorites.db"
fileprivate let defaultTableName = "favorites"

final class FavoritesService {
    enum Changes {
        case added(RadioStation)
        case removed(RadioStation)
    }
    
    let tableName: String
    let databaseName: String
    
    private(set) var available: Bool = false
    
    private let changesRelay = PublishRelay<Changes>()
    var changes: Signal<Changes> { changesRelay.asSignal() }
    
    var path: String? {
        try? FileManager.default.url(for: .documentDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: false)
        .appendingPathComponent(databaseName).path
    }
        
    private var database: OpaquePointer?
    
    deinit {
        if let database {
            sqlite3_close(database)
        }
    }
    
    init(tableName: String = defaultTableName, databaseName: String = defaultDatabaseName) {
        self.tableName = tableName
        self.databaseName = databaseName
        
        openDatabase()
        available = createTable()
    }
    
    private func openDatabase() {
        guard let path else {
            return
        }
        
        if SQLITE_OK != sqlite3_open(path, &database) {
            sqlite3_close(database)
            database = nil
        }
    }
    
    private func createTable() -> Bool {
        let sql = """
        CREATE TABLE IF NOT EXISTS \(tableName)(
        favorited_epoch INTEGER,
        changeuuid TEXT NOT NULL,
        stationuuid TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        url_resolved TEXT NOT NULL,
        homepage TEXT NOT NULL,
        favicon TEXT NOT NULL,
        tags TEXT NOT NULL,
        country TEXT NOT NULL,
        countrycode TEXT NOT NULL,
        state TEXT NOT NULL,
        language TEXT NOT NULL,
        languagecodes TEXT NOT NULL,
        codec TEXT NOT NULL,
        bitrate INTEGER
        );
        """
        
        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
        guard result == SQLITE_OK else {
            return false
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        return sqlite3_step(statement) == SQLITE_DONE
    }
    
    private func run(sql: String, afterStep: ((_ result: Int32, _ statement: OpaquePointer?) -> Void)? = nil) -> Int32 {
        var statement: OpaquePointer?
        let prepared =  sqlite3_prepare_v2(database, sql, -1, &statement, nil)
        
        guard prepared == SQLITE_OK else {
            return prepared
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        let result = sqlite3_step(statement)
        
        afterStep?(result, statement)
        
        return result
    }
    
    func fetch(paging: (offset: Int, limit: Int)? = nil) -> [RadioStation] {
        guard available else { return [] }
        
        var sql = """
        SELECT
        changeuuid,
        stationuuid,
        name,
        url,
        url_resolved,
        homepage,
        favicon,
        tags,
        country,
        countrycode,
        state,
        language,
        languagecodes,
        codec,
        bitrate
        FROM \(tableName) ORDER BY favorited_epoch
        """
        
        if let paging {
            sql += " LIMIT \(paging.limit) OFFSET \(paging.offset);"
        } else {
            sql += ";"
        }

        var statement: OpaquePointer?
        let result = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
            
        guard result == SQLITE_OK else {
            return []
        }
        
        defer {
            sqlite3_finalize(statement)
        }
        
        func stringFrom(column: Int32) -> String {
            String(cString: sqlite3_column_text(statement, column))
        }
        
        var stations: [RadioStation] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            let station = RadioStation(changeuuid: stringFrom(column: 0),
                                       stationuuid: stringFrom(column: 1),
                                       name: stringFrom(column: 2),
                                       url: stringFrom(column: 3),
                                       url_resolved: stringFrom(column: 4),
                                       homepage : stringFrom(column: 5),
                                       favicon: stringFrom(column: 6),
                                       tags: stringFrom(column: 7),
                                       country: stringFrom(column: 8),
                                       countrycode: stringFrom(column: 9),
                                       state: stringFrom(column: 10),
                                       language: stringFrom(column: 11),
                                       languagecodes: stringFrom(column: 12),
                                       codec: stringFrom(column: 13),
                                       bitrate: Int(sqlite3_column_int(statement, 14)),
                                       favorited: true)
            stations.append(station)
        }
        
        return stations
    }
    
    
    func fetch(paging: (offset: Int, limit: Int)? = nil, completion: @escaping ([RadioStation]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completion(fetch(paging: paging))
        }
    }
    
    
    func add(_ station: RadioStation) -> Bool {
        guard available else { return false }
        
        let sql = """
        INSERT INTO \(tableName)(
        favorited_epoch,
        changeuuid,
        stationuuid,
        name,
        url,
        url_resolved,
        homepage,
        favicon,
        tags,
        country,
        countrycode,
        state,
        language,
        languagecodes,
        codec,
        bitrate)
        values (
        \(Date().timeIntervalSince1970),
        '\(station.changeuuid)',
        '\(station.stationuuid)',
        '\(station.name)',
        '\(station.url)',
        '\(station.url_resolved)',
        '\(station.homepage)',
        '\(station.favicon)',
        '\(station.tags)',
        '\(station.country)',
        '\(station.countrycode)',
        '\(station.state)',
        '\(station.language)',
        '\(station.languagecodes)',
        '\(station.codec)',
        '\(station.bitrate)'
        );
        """
        
        if run(sql: sql) == SQLITE_DONE {
            changesRelay.accept(.added(station))
            return true
        }
        
        return false
    }
    
    func add( station: RadioStation, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completion(add(station))
        }
    }
    
    func remove(_ station: RadioStation) -> Bool {
        guard available else { return false }
        
        let sql = "DELETE FROM \(tableName) WHERE stationuuid = '\(station.stationuuid)';"
        
        if run(sql: sql) == SQLITE_DONE {
            changesRelay.accept(.removed(station))
            return true
        }
        return false
    }
    
    func remove(_ station: RadioStation, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completion(remove(station))
        }
    }
    
    func removeAll() -> Bool {
        guard available else { return false }
        
        let sql = "DELETE FROM \(tableName);"
        
        return run(sql: sql) == SQLITE_DONE
    }
    
    func removeAll(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completion(removeAll())
        }
    }
    
    func contains(stationuuid: String) -> Bool {
        guard available else { return false }
        
        let sql = "SELECT count(*) FROM \(tableName) WHERE stationuuid == '\(stationuuid)';"
        
        var contains = false
        _ = run(sql: sql) { result, statement in
            if result == SQLITE_DONE {
                contains = false
            } else if result == SQLITE_ROW {
                contains = sqlite3_column_int(statement, 0) > 0
            }
        }
        
        return contains
    }
    
    func contains(stationuuid: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completion(contains(stationuuid: stationuuid))
        }
    }
    
    func filterContained(_ stationuuids: [String]) -> [String] {
        let values = stationuuids
            .map { "'\($0)'"}
            .joined(separator: ",")
        let sql = "SELECT stationuuid FROM \(tableName) WHERE stationuuid IN (\(values));"
        
        var favorites: [String] = []
        _ = run(sql: sql) { result, statement in
            var result = result
            
            while result == SQLITE_ROW {
                let uuid = String(cString: sqlite3_column_text(statement, 0))
                favorites.append(uuid)
                
                result = sqlite3_step(statement)
            }
        }
        
        return favorites
    }
    
    func filterContained(_ stationuuids: [String], completion: @escaping ([String]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            completion(filterContained(stationuuids))
        }
    }
}
