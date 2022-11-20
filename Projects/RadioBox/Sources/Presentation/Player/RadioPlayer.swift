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

extension PlayerStatus {
    init?(from timeControlStatus: AVPlayer.TimeControlStatus?) {
        switch timeControlStatus {
        case .playing: self = .playing
        case .paused: self = .stopped
        case .waitingToPlayAtSpecifiedRate: self =  .waitingToPlay
        default: return nil
        }
    }
}

class RadioPlayer: NSObject, Player {
    private let statusSubject = CurrentValueSubject<PlayerStatus, Never>(.disabled)
    var status: AnyPublisher<PlayerStatus, Never> { statusSubject.eraseToAnyPublisher() }
    
    private let stationSubject = CurrentValueSubject<RadioStation?, Never>(nil)
    var station: AnyPublisher<RadioStation?, Never> { stationSubject.eraseToAnyPublisher() }
    
    private let errorSubject = PassthroughSubject<Error, Never>()
    var error: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }
    
    
    private let player = AVPlayer()
    private var playerItem: AVPlayerItem?
    
    deinit {
        player.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override init() {
        super.init()
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new ], context: nil)
    }

    func toggle() {
        guard player.currentItem != nil else { return }
        
        switch player.timeControlStatus {
        case .playing, .waitingToPlayAtSpecifiedRate:
            player.pause()
        case .paused:
            player.play()
        default:
            break
        }
    }
    
    func play(station: RadioStation) {
        // dispose old item
        
        playerItem?.removeObserver(self, forKeyPath: "status")
        
        player.pause()
        player.cancelPendingPrerolls()
        
        // set new item
        playerItem = AVPlayerItem(url: station.url_resolved)
        player.replaceCurrentItem(with: playerItem)
        
        playerItem?.addObserver(self, forKeyPath: "status", options: [.initial, .new ], context: nil)
        
        player.play()
        
        stationSubject.send(station)
    }
    
    func stop() {
        player.pause()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "timeControlStatus":
            if let rawValue = change?[.newKey] as? AVPlayer.TimeControlStatus.RawValue {
                print("timeControlStatus: \(rawValue)")
                
                // ignore changes after an error of player item
                guard playerItem?.error == nil else {
                    return ;
                }
                
                if let status = PlayerStatus(from: AVPlayer.TimeControlStatus(rawValue: rawValue)) {
                    statusSubject.send(status)
                }
            }
        case "status":
            if let rawValue = change?[.newKey] as? AVPlayerItem.Status.RawValue {
                let failed = rawValue == AVPlayerItem.Status.failed.rawValue
                print("item.status: \(failed)")
                
                if failed {
                    statusSubject.send(.disabled)
                    
                    if let error = playerItem?.error {
                        errorSubject.send(error)
                    }
                }
            }
        default:
            break
        }
    }
}
