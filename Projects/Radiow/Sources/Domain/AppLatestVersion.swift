//
//  AppLatestVersion.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/12/09.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

struct AppVersion {
    let major: String
    let minor: String
    let patch: String
    
    let value: String
    
    init(value: String) {
        self.value = value
        
        let tokens = value.split(separator: ".", maxSplits: 2).map { String($0) }
        
        switch tokens.count {
        case 1:
            major = tokens[0]
            minor = "0"
            patch = "0"
            
        case 2:
            major = tokens[0]
            minor = tokens[1]
            patch = "0"
            
        case 3...:
            major = tokens[0]
            minor = tokens[1]
            patch = tokens[2]
        default:
            major = value
            minor = "0"
            patch = "0"
            
        }
    }
}

extension AppVersion: Comparable {
    static func ==(_ lhs: AppVersion, _ rhs: AppVersion) -> Bool {
        lhs.value == rhs.value
    }
    
    static func >(_ lhs: AppVersion, _ rhs: AppVersion) -> Bool {
        lhs.major > rhs.major ||
        lhs.minor > rhs.minor ||
        lhs.patch > rhs.patch
    }

    static func <(_ lhs: AppVersion, _ rhs: AppVersion) -> Bool {
        rhs > lhs
    }
}
