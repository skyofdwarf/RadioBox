//
//  RadioBrowserServerState.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

public struct RadioBrowserServerState: Decodable {
    public let supported_version: Int
    public let software_version: String
    public let status: String
    public let stations: Int
    public let stations_broken: Int
    public let tags: Int
    public let clicks_last_hour: Int
    public let clicks_last_day: Int
    public let languages: Int
    public let countries: Int
}
