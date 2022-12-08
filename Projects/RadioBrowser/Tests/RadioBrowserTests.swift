import Foundation
import XCTest
import Moya

@testable import RadioBrowser

public final class StubBrowser: APIService {
    public init(userAgent: String = "Radiow/1.0.0") {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)),
        ]
        let endpointClosure = { (target: MultiTarget) -> Endpoint in
            MoyaProvider.defaultEndpointMapping(for: target)
                .adding(newHTTPHeaderFields: ["User-Agent": userAgent])
        }

        let provider = MoyaProvider<MultiTarget>(endpointClosure: endpointClosure,
                                                 stubClosure: MoyaProvider.immediatelyStub,
                                                 plugins: plugins)
        
        super.init(provider: provider)
    }
}

final class RadioBrowserTests: XCTestCase {
    func test_target_serverStats() async throws {
        let api = StubBrowser()
        let _: RadioBrowserServerState = try await api.request(RadioBrowserTarget.serverStats)
    }
    
    func test_target_serverMirror() async throws {
        let api = StubBrowser()
        let _: [RadioBrowserServerMirror] = try await api.request(RadioBrowserTarget.serverMirror)
    }
    
    func test_target_serverConfig() async throws {
        let api = StubBrowser()
        let _: RadioBrowserServerConfig = try await api.request(RadioBrowserTarget.serverConfig)
    }
    
    func test_target_searchStation() async throws {
        let api = StubBrowser()
        let options: [SearchStationOptions] = [.tag("korea"), .limit(2) ]
        let _: [RadioBrowserStation] = try await api.request(RadioBrowserTarget.searchStation(options))
    }
    
    func test_target_allStations() async throws {
        let api = StubBrowser()
        let options: [SearchStationOptions] = [ .limit(1) ]
        let _: [RadioBrowserStation] = try await api.request(RadioBrowserTarget.allStations(options))
    }
    
    func test_target_voteStation() async throws {
        let api = StubBrowser()
        let _: RadioBrowserVoteStationResponse = try await api.request(RadioBrowserTarget.voteStation("no station"))
    }
    
    func test_target_clickStation() async throws {
        let api = StubBrowser()
        let _: RadioBrowserClickStationResponse = try await api.request(RadioBrowserTarget.clickStation("no station"))
    }
    
    func test_target_recentClickStations() async throws {
        let api = StubBrowser()
        let _: [RadioBrowserStation] = try await api.request(RadioBrowserTarget.recentClickStations(offset: 0, limit: 1))
    }
    
    func test_target_mostClickedStations() async throws {
        let api = StubBrowser()
        let _: [RadioBrowserStation] = try await api.request(RadioBrowserTarget.mostClickedStations(offset: 0, limit: 1))
    }
    
    func test_target_mostVotedStations() async throws {
        let api = StubBrowser()
        let _: [RadioBrowserStation] = try await api.request(RadioBrowserTarget.mostVotedStations(offset: 0, limit: 1))
    }
}
