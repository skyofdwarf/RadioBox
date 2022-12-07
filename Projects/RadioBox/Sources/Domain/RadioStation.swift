//
//  RadioStation.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/17.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import RadioBrowser

struct RadioStation {
    let changeuuid: String
    let stationuuid: String
    let name: String
    let url: String
    let url_resolved: String
    let homepage: String
    let favicon: String
    let tags: String
    let country: String
    let countrycode: String
    let state: String
    let language: String
    let languagecodes: String
    let codec: String
    let bitrate: Int
    var favorited = false
}

extension RadioStation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(stationuuid)
        hasher.combine(favorited)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.stationuuid == rhs.stationuuid && lhs.favorited == rhs.favorited
    }
}

extension RadioStation {
    init(_ station: RadioBrowserStation) {
        self.changeuuid = station.changeuuid
        self.stationuuid = station.stationuuid
        self.name = station.name
        self.url = station.url
        self.url_resolved = station.url_resolved
        self.homepage = station.homepage
        self.favicon = station.favicon
        self.tags = station.tags
        self.country = station.country
        self.countrycode = station.countrycode
        self.state = station.state
        self.language = station.language
        self.languagecodes = station.languagecodes
        self.codec = station.codec
        self.bitrate = station.bitrate
    }
}
