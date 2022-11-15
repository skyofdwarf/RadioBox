//
//  RadioBrowserClickStationResponse.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation


struct RadioBrowserClickStationResponse: Decodable {
    let ok: Bool
    let message: String
    let stationuuid: String
    let name: String
    let url: URL
}
