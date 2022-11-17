//
//  RadioBrowserServerStation.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

public struct RadioBrowserStation: Decodable {    
    public let changeuuid: String
    public let stationuuid: String
    public let name: String
    public let url: URL
    public let url_resolved: URL
    public let homepage: URL
    public let favicon: String
    public let tags: String
    public let country: String
    public let countrycode: String
    public let state: String
    public let language: String
    public let languagecodes: String
    public let votes: Int
    public let lastchangetime: String?
    public let lastchangetime_iso8601: String?
    public let codec: String
    public let bitrate: Int
    public let hls: Int
    public let lastcheckok: Int
    public let lastchecktime: String?
    public let lastchecktime_iso8601: String?
    public let lastcheckoktime: String?
    public let lastcheckoktime_iso8601: String?
    public let lastlocalchecktime: String?
    public let lastlocalchecktime_iso8601: String?
    public let clicktimestamp: String?
    public let clicktimestamp_iso8601: String?
    public let clickcount: Int
    public let clicktrend: Int
    public let ssl_error: Int
    public let geo_lat: Double?
    public let geo_long: Double?
    public let has_extended_info: Bool
}
