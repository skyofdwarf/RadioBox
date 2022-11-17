//
//  RadioBrowserClickStationResponse.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

public struct RadioBrowserClickStationResponse: Decodable {
    public let ok: Bool
    public let message: String
    public let stationuuid: String
    public let name: String
    public let url: URL
}
