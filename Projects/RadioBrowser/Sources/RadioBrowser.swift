import Foundation
import Moya

// https://api.radio-browser.info/

open class RadioBrowser: APIService {
    public convenience init(userAgent: String = "Radiow/0.1.0") {
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
        
        let endpointClosure = { (target: MultiTarget) -> Endpoint in
            MoyaProvider.defaultEndpointMapping(for: target)
                .adding(newHTTPHeaderFields: ["User-Agent": userAgent])
        }

        let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure,
                                                 plugins: plugins)
        
        self.init(provider: provider)
    }
}
