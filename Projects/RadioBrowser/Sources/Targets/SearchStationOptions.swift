//
//  SearchStationOptions.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

public enum SearchStationOptions {
    case name(String)
    case tag(String)
    case countrycode(String)
    case offset(Int)
    case limit(Int)
    case isHttps(Bool)
    case order(Order)
    case hidebroken(Bool)
    
    public enum Order: String {
        case name, url, homepage, favicon, tags, country, state, language, votes, codec, bitrate, lastcheckok, lastchecktime, clicktimestamp, clickcount, clicktrend, changetimestamp, random
    }
    
    var parameter: [String: Encodable] {
        switch self {
        case .name(let name):
            return ["name": name]
        case .tag(let tag):
            return ["tag": tag]
        case .countrycode(let code):
            return ["countrycode": code]
        case .offset(let offset):
            return ["offset": offset]
        case .limit(let limit):
            return ["limit": limit]
        case .isHttps(let isHttps):
            return ["is_https": isHttps]
        case .order(let order):
            return ["order": order.rawValue]
        case .hidebroken(let hidebroken):
            return ["hidebroken": hidebroken]
        }
    }
}
