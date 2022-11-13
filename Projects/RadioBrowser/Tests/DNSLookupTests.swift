//
//  DNSLookup.swift
//  RadioBrowserTests
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import XCTest
import CFNetwork
@testable import RadioBrowser

final class DNSLookupTests: XCTestCase {
    func test_dns_lookup() async throws {
        let addrs = try await DNSLookup.lookup(hostname: "localhost")
        
        XCTAssert(!addrs.isEmpty)
        XCTAssertTrue(addrs.contains("127.0.0.1"))
    }
    
    func test_reverse_dns_lookup() async throws {
        let host = CFHostCreateWithName(kCFAllocatorDefault, "localhost" as CFString).takeRetainedValue()
        let resolved = CFHostStartInfoResolution(host, CFHostInfoType.addresses, nil)
        XCTAssertTrue(resolved)
        
        // [Data<sockaddr>]
        guard let sockaddrs = CFHostGetAddressing(host, nil)?.takeUnretainedValue() as? [Data] else {
            XCTFail("Failed to get address")
            return
        }
        
        var names: [String] = []
        for addr in sockaddrs {
            names.append(contentsOf: try await DNSLookup.reverseLookup(sockaddr: addr))
        }
        
        XCTAssertTrue(names.contains("localhost"))
    }
    
    func test_reverse_lookup_from_hostname() async throws {
        let names = try await DNSLookup.reverseLookup(hostname: "localhost")
        
        XCTAssert(!names.isEmpty)
        XCTAssertTrue(names.contains("localhost"))
    }
}
