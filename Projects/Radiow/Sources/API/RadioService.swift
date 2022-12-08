//
//  RadioService.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/16.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import RadioBrowser
import Moya

final class RadioService: RadioBrowser {
    init(baseURL: URL, stubClosure: @escaping MoyaProvider<MultiTarget>.StubClosure = MoyaProvider.neverStub) {
#if DEBUG
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
            //AccessTokenPlugin(tokenClosure: { _ in accessToken })
        ]
#else
        
        let plugins: [PluginType] = [
            //AccessTokenPlugin(tokenClosure: { _ in accessToken })
        ]
#endif
        
        let provider = MoyaProvider<MultiTarget>(stubClosure: stubClosure,
                                                 plugins: plugins)
        
        super.init(provider: provider)
    }
    
    struct mock {
        static func delayedStub(baseURL: URL, seconds: TimeInterval) -> RadioService {
            RadioService(baseURL: baseURL, stubClosure: MoyaProvider<MultiTarget>.delayedStub(seconds))
        }
        
        static func immediatelyStub(baseURL: URL) -> RadioService {
            RadioService(baseURL: baseURL, stubClosure: MoyaProvider<MultiTarget>.immediatelyStub)
        }
    }
}
