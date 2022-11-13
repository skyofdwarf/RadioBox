//
//  RadioBrowserServerState.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

struct RadioBrowserServerState: Decodable {
    let supported_version: Int
    let software_version: String
    let status: String
    let stations: Int
    let stations_broken: Int
    let tags: Int
    let clicks_last_hour: Int
    let clicks_last_day: Int
    let languages: Int
    let countries: Int
}
