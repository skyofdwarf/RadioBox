//
//  FavoritesServiceTests.swift
//  RadiowTests
//
//  Created by YEONGJUNG KIM on 2022/12/05.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import XCTest
@testable import Radiow

final class FavoritesServiceTests: XCTestCase {
    let db = FavoritesService(tableName: "test_table", databaseName: "test.db")
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        _ = db.removeAll()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAvailablity() throws {
        XCTAssertTrue(db.available)
    }
    
    func testEmptyRows() throws {
        let stations = db.fetch()
        
        XCTAssertTrue(stations.isEmpty)
    }
    
    func testAddStation() throws {
        let station = RadioStation(changeuuid: "changeuuid",
                                   stationuuid: "stationuuid",
                                   name: "name",
                                   url: "url",
                                   url_resolved: "url_resolved",
                                   homepage: "homepage",
                                   favicon: "favicon",
                                   tags: "tags",
                                   country: "country",
                                   countrycode: "countrycode",
                                   state: "state",
                                   language: "language",
                                   languagecodes: "languagecodes",
                                   codec: "codec",
                                   bitrate: 1)
        
        // when
        XCTAssertTrue(db.add(station))
        
        // then
        let stations = db.fetch()
        
        XCTAssertEqual(stations.count, 1)
    }
    
    func testRemoveStation() throws {
        // given
        let station = RadioStation(changeuuid: "changeuuid",
                                   stationuuid: "stationuuid",
                                   name: "name",
                                   url: "url",
                                   url_resolved: "url_resolved",
                                   homepage: "homepage",
                                   favicon: "favicon",
                                   tags: "tags",
                                   country: "country",
                                   countrycode: "countrycode",
                                   state: "state",
                                   language: "language",
                                   languagecodes: "languagecodes",
                                   codec: "codec",
                                   bitrate: 1)
        XCTAssertTrue(db.add(station))
        var stations = db.fetch()
        XCTAssertEqual(stations.count, 1)
        
        // when
        XCTAssertTrue(db.remove(station))
        
        // then
        stations = db.fetch()
        
        XCTAssertTrue(stations.isEmpty)
    }
    
    func testAddDuplicatedStation() throws {
        let station = RadioStation(changeuuid: "changeuuid",
                                   stationuuid: "stationuuid",
                                   name: "name",
                                   url: "url",
                                   url_resolved: "url_resolved",
                                   homepage: "homepage",
                                   favicon: "favicon",
                                   tags: "tags",
                                   country: "country",
                                   countrycode: "countrycode",
                                   state: "state",
                                   language: "language",
                                   languagecodes: "languagecodes",
                                   codec: "codec",
                                   bitrate: 1)
        
        XCTAssertTrue(db.add(station))
        
        var stations = db.fetch()
        
        XCTAssertEqual(stations.count, 1)
        
        // when
        XCTAssertFalse(db.add(station))
        
        // then
        stations = db.fetch()
        
        XCTAssertEqual(stations.count, 1)
    }
    
    func testContainsStation() throws {
        let station = RadioStation(changeuuid: "changeuuid",
                                   stationuuid: "stationuuid",
                                   name: "name",
                                   url: "url",
                                   url_resolved: "url_resolved",
                                   homepage: "homepage",
                                   favicon: "favicon",
                                   tags: "tags",
                                   country: "country",
                                   countrycode: "countrycode",
                                   state: "state",
                                   language: "language",
                                   languagecodes: "languagecodes",
                                   codec: "codec",
                                   bitrate: 1)
        
        XCTAssertTrue(db.add(station))
        
        // when
        let contained = db.contains(stationuuid: station.stationuuid)
        let notContained = db.contains(stationuuid: "no uuid")
   
        // then
        XCTAssertTrue(contained)
        XCTAssertFalse(notContained)
    }
    
    func testfilterContained() throws {
        let stations = [
            RadioStation(changeuuid: "changeuuid",
                         stationuuid: "1",
                         name: "name",
                         url: "url",
                         url_resolved: "url_resolved",
                         homepage: "homepage",
                         favicon: "favicon",
                         tags: "tags",
                         country: "country",
                         countrycode: "countrycode",
                         state: "state",
                         language: "language",
                         languagecodes: "languagecodes",
                         codec: "codec",
                         bitrate: 1),
            RadioStation(changeuuid: "changeuuid",
                         stationuuid: "2",
                         name: "name",
                         url: "url",
                         url_resolved: "url_resolved",
                         homepage: "homepage",
                         favicon: "favicon",
                         tags: "tags",
                         country: "country",
                         countrycode: "countrycode",
                         state: "state",
                         language: "language",
                         languagecodes: "languagecodes",
                         codec: "codec",
                         bitrate: 1)
            ]
        
        stations.forEach {
            _ = db.add($0)
        }
        
        let uuids = stations.map(\.stationuuid)
        
        // when
        let filtered = db.filterContained(uuids + ["not contained"])
        
        // then
        XCTAssertEqual(filtered, uuids)
    }
}
