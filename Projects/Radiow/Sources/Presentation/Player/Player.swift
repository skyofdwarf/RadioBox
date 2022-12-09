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
    var status: PlayerStatus { get }
    var station: RadioStation? { get }
    var streamTitle: (title: String, artist: String?) { get }
    var streamArtwork: URL? { get }
    
    var statusPublisher: AnyPublisher<PlayerStatus, Never> { get }
    var stationPublisher: AnyPublisher<RadioStation?, Never> { get }
    var streamTitlePublisher: AnyPublisher<(title: String, artist: String?), Never> { get }
    var streamArtworkPublisher: AnyPublisher<URL?, Never> { get }

    var errorPublisher: AnyPublisher<Error, Never> { get }
    
    var isPlaying: Bool { get }
    
    func play(station: RadioStation)
    func resume()
    func stop()
    
    @discardableResult
    func toggle() -> Bool
}
