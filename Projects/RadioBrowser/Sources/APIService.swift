//
//  APIService.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import Moya
import CombineMoya
import Combine

open class APIService {
    let provider: MoyaProvider<MultiTarget>
    
    public init(provider: MoyaProvider<MultiTarget> = MoyaProvider<MultiTarget>()) {
        self.provider = provider
    }
    
    public convenience init() {
#if DEBUG
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        ]
#else
        let plugins: [PluginType] = []
#endif
        let provider = MoyaProvider<MultiTarget>(plugins: plugins)
        
        self.init(provider: provider)
    }
    
    // Raw request method
    public func request(_ target: TargetType, completion: @escaping (Result<Response, MoyaError>) -> Void) {
        provider.request(MultiTarget(target)) { completion($0) }
    }

    // Mapping requests
    public func request<D: Decodable>(_ target: TargetType, success: @escaping (D) -> (), failure: @escaping (Error) -> ()) {
        request(target) { result in
            switch result {
            case .success(let response):
                do {
                    let successfulResponse = try response.filterSuccessfulStatusCodes()
                    success(try successfulResponse.map(D.self))
                } catch {
                    failure(error)
                }
                
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    public func request<D: Decodable>(_ target: TargetType) -> AnyPublisher<D, MoyaError> {
        provider.requestPublisher(MultiTarget(target))
            .filterSuccessfulStatusCodes()
            .map(D.self)
            .eraseToAnyPublisher()
    }
    
    public func request<D: Decodable>(_ target: TargetType) async throws -> D {
        try await withCheckedThrowingContinuation { continuation in
            request(target) {
                continuation.resume(returning: $0)
            } failure: {
                continuation.resume(throwing: $0)
            }
        }
    }
        
    // Raw request.rx method
//    public func request<D: Decodable>(_ target: TargetType) -> Observable<D> {
//        provider.rx
//            .request(MultiTarget(target))
//            .filterSuccessfulStatusCodes()
//            .map(D.self)
//            .asObservable()
//    }
}
