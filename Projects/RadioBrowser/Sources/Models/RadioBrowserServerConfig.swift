//
//  RadioBrowserServerConfig.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

public struct RadioBrowserServerConfig: Decodable {
    public let check_enabled: Bool
    public let prometheus_exporter_enabled: Bool
    public let pull_servers: [String]
    public let tcp_timeout_seconds: Int
    public let broken_stations_never_working_timeout_seconds: Int
    public let broken_stations_timeout_seconds: Int
    public let checks_timeout_seconds: Int
    public let click_valid_timeout_seconds: Int
    public let clicks_timeout_seconds: Int
    public let mirror_pull_interval_seconds: Int
    public let update_caches_interval_seconds: Int
    public let server_name: String
    public let server_location: String
    public let server_country_code: String
    public let check_retries: Int
    public let check_batchsize: Int
    public let check_pause_seconds: Int
    public let api_threads: Int
    public let cache_type: String
    public let cache_ttl: Int
    public let language_replace_filepath: String
    public let language_to_code_filepath: String
}
