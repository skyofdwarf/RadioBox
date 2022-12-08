//
//  Player.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/18.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import Combine

enum PlayerStatus {
    case playing
    case stopped
    case waitingToPlay
    case disabled
    
    @discardableResult
    mutating func toggle() -> Self {
        switch self {
        case .playing: self = .stopped
        case .stopped: self = .playing
        default: break
        }
        return self
    }
}

protocol Player: AnyObject {
    var status: AnyPublisher<PlayerStatus, Never> { get }
    var station: AnyPublisher<RadioStation?, Never> { get }
    var error: AnyPublisher<Error, Never> { get }
    var streamTitle: AnyPublisher<(title: String, artist: String?), Never> { get }
    var streamArtwork: AnyPublisher<URL?, Never> { get }
    
    func play(station: RadioStation)
    func resume()
    func stop()
    
    @discardableResult
    func toggle() -> Bool
}
