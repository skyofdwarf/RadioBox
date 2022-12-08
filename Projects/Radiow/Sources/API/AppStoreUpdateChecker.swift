//
//  AppStoreUpdateChecker.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/12/09.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

class AppStoreUpdateChecker: AppUpdateChecker {
    private let appleId = "545102882"
    
    func check(_ complection: @escaping (AppVersion?) -> Void) {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appleId)") else {
            complection(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, res, error in
            guard let data,
                  let lookup = try? JSONDecoder().decode(AppStoreLookupResponse.self, from: data),
                  let information = lookup.results.first
            else {
                complection(nil)
                return
            }
            
            complection(AppVersion(value: information.version))
        }
        
        task.resume()
    }
}

struct AppStoreLookupResponse: Decodable {
    let results: [AppInformation]
    
    struct AppInformation: Decodable {
        let trackViewUrl: String
        let bundleId: String
        let version: String
   }
}
