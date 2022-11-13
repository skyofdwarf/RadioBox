//
//  DNSLookup.swift
//  RadioBrowser
//
//  Created by YEONGJUNG KIM on 2022/11/13.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import CFNetwork
import Network

public final class DNSLookup {
    enum Error: Swift.Error {
        case dnsLookupFailed
        case reverseLookupFailed
        case noIPv4
    }
    
    public static func lookup(hostname: String) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                continuation.resume(returning: try lookup(hostname: hostname))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public static func lookup(hostname: String) throws -> [String] {
        let host = CFHostCreateWithName(kCFAllocatorDefault, hostname as CFString).takeRetainedValue()
        let resolved = CFHostStartInfoResolution(host, CFHostInfoType.addresses, nil)
        guard resolved else {
            throw Error.dnsLookupFailed
        }
        
        // [Data<sockaddr>]
        let sockaddrs = CFHostGetAddressing(host, nil)?.takeUnretainedValue()
        guard let sockaddrs = sockaddrs as? [Data] else {
            throw Error.dnsLookupFailed
        }
        
        // only IPv4
        return sockaddrs
            .filter {
                let family = $0.withUnsafeBytes { p -> sa_family_t? in
                    guard let baseAddress = p.baseAddress else {
                        return nil
                    }
                    return baseAddress.assumingMemoryBound(to: sockaddr_storage.self).pointee.ss_family
                }
                                
                guard let family, family == numericCast(AF_INET) else {
                    return false
                }
                return true
            }
            .compactMap(addressToString)
    }
    
    public static func reverseLookup(hostname: String) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                continuation.resume(returning: try reverseLookup(hostname: hostname))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Gets all hostnames for each ip addresses of given `hostname`
    ///
    /// lookup `hostname` then reverse lookup up found addresses.
    /// - Parameter hostname: hostname to lookup
    /// - Returns: hostnames reverse looked up
    public static func reverseLookup(hostname: String) throws -> [String] {
        let host = CFHostCreateWithName(kCFAllocatorDefault, hostname as CFString).takeRetainedValue()
        let resolved = CFHostStartInfoResolution(host, CFHostInfoType.addresses, nil)
        guard resolved else {
            throw Error.dnsLookupFailed
        }
        
        // [Data<sockaddr>]
        let sockaddrs = CFHostGetAddressing(host, nil)?.takeUnretainedValue()
        guard let sockaddrs = sockaddrs as? [Data] else {
            throw Error.dnsLookupFailed
        }
        
        var foundNames: [String] = []
        for sockaddr in sockaddrs {
            foundNames.append(contentsOf: try reverseLookup(sockaddr: sockaddr))
        }
        
        return foundNames
    }
    
    public static func reverseLookup(sockaddr: Data) async throws -> [String] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                continuation.resume(returning: try reverseLookup(sockaddr: sockaddr))
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public static func reverseLookup(sockaddr: Data) throws -> [String] {
        let family = sockaddr.withUnsafeBytes { p -> sa_family_t? in
            guard let baseAddress = p.baseAddress else {
                return nil
            }
            return baseAddress.assumingMemoryBound(to: sockaddr_storage.self).pointee.ss_family
        }
        
        // ignore ipv6
        guard let family, family == numericCast(AF_INET) else {
            return []
        }
        
        let host = CFHostCreateWithAddress(kCFAllocatorDefault, sockaddr as CFData).takeRetainedValue()
        let resolved = CFHostStartInfoResolution(host, CFHostInfoType.names, nil)
        guard resolved else {
            throw Error.reverseLookupFailed
        }
        
        // [String]
        return CFHostGetNames(host, nil)?.takeUnretainedValue() as? [String] ?? []
    }
}

// https://stackoverflow.com/questions/24794997/convert-nsdata-to-sockaddr-struct-in-swift
func addressToString(data: Data) -> String? {
    data.withUnsafeBytes { p -> String? in
        guard let baseAddress = p.baseAddress else {
            return nil
        }
        
        let family = baseAddress.assumingMemoryBound(to: sockaddr_storage.self).pointee.ss_family
        if family == numericCast(AF_INET) {
            var sin_addr = baseAddress.assumingMemoryBound(to: sockaddr_in.self).pointee.sin_addr
            
            return withUnsafeBytes(of: &sin_addr) { p -> String? in
                guard let baseAddress = p.baseAddress else {
                    return nil
                }
                
                let data = Data(bytes: baseAddress, count: MemoryLayout<in_addr>.size)
                return data.map { String(format: "%d", $0) }.joined(separator: ".")
            }
        } else if family == numericCast(AF_INET6) {
            var sin6_addr = baseAddress.assumingMemoryBound(to: sockaddr_in6.self).pointee.sin6_addr
            
            return withUnsafeBytes(of: &sin6_addr) { p -> String? in
                guard let baseAddress = p.baseAddress else {
                    return nil
                }
                let data = Data(bytes: baseAddress, count: MemoryLayout<in6_addr>.size)
                let ip6 = IPv6Address(data)
                return ip6?.debugDescription
            }
        }
        return nil
    }
}
