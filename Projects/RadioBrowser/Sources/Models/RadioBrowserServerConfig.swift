//
//  RadioBrowserServerConfig.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

public struct RadioBrowserServerConfig: Decodable {
    let check_enabled: Bool
    let prometheus_exporter_enabled: Bool
    let pull_servers: [String]
    let tcp_timeout_seconds: Int
    let broken_stations_never_working_timeout_seconds: Int
    let broken_stations_timeout_seconds: Int
    let checks_timeout_seconds: Int
    let click_valid_timeout_seconds: Int
    let clicks_timeout_seconds: Int
    let mirror_pull_interval_seconds: Int
    let update_caches_interval_seconds: Int
    let server_name: String
    let server_location: String
    let server_country_code: String
    let check_retries: Int
    let check_batchsize: Int
    let check_pause_seconds: Int
    let api_threads: Int
    let cache_type: String
    let cache_ttl: Int
    let language_replace_filepath: String
    let language_to_code_filepath: String
}
