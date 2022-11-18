//
//  RadioPlayer.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/18.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

enum PlayerStatus {
    case playing
    case stopped
    
    @discardableResult
    mutating func toggle() -> Self {
        switch self {
        case .playing: self = .stopped
        case .stopped: self = .playing
        }
        return self
    }
}

protocol Player {
    var status: AnyPublisher<PlayerStatus, Never> { get }
    var station: AnyPublisher<RadioStation?, Never> { get }
    
    func play(station: RadioStation)
    func stop()
}

class RadioPlayer: Player {
    private let statusSubject = CurrentValueSubject<PlayerStatus, Never>(.stopped)
    var status: AnyPublisher<PlayerStatus, Never> { statusSubject.eraseToAnyPublisher() }
    
    private let stationSubject = CurrentValueSubject<RadioStation?, Never>(nil)
    var station: AnyPublisher<RadioStation?, Never> { stationSubject.eraseToAnyPublisher() }
    
    private var player: AVPlayer?
    
    private var timeObserver: Any?
    
    @discardableResult
    func togglePlay() -> PlayerStatus {
        .playing
    }
    
    func play(station: RadioStation) {
        player?.pause()
        player?.cancelPendingPrerolls()
        
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        player = AVPlayer(url: station.url_resolved)
        
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600),
                                        queue: DispatchQueue.main,
                                        using: { time in
            print("time observer: \(time), \(time.seconds)")
        })
        
        timeObserver = player?.observe(\.timeControlStatus, changeHandler: { player, change in
            print("change.newValue: \(change.newValue)")
        })
        
        player?.play()
        statusSubject.send(.playing)
        stationSubject.send(station)
    }
    
    func stop() {
        player?.pause()
        statusSubject.send(.stopped)
    }
}
