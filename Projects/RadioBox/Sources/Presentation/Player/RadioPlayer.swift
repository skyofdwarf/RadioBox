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

class RadioPlayer: NSObject, Player {
    private let statusSubject = CurrentValueSubject<PlayerStatus, Never>(.stopped)
    var status: AnyPublisher<PlayerStatus, Never> { statusSubject.eraseToAnyPublisher() }
    
    private let stationSubject = CurrentValueSubject<RadioStation?, Never>(nil)
    var station: AnyPublisher<RadioStation?, Never> { stationSubject.eraseToAnyPublisher() }
    
    private var player: AVPlayer?
    
    private var timeObserver: Any?

    func toggle() {
        guard let player else { return }
            
        if player.timeControlStatus == .paused {
            player.play()
        } else {
            player.pause()
        }
    }
    
    func play(station: RadioStation) {
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        player?.pause()
        player?.cancelPendingPrerolls()
        
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        
        player = AVPlayer(url: station.url_resolved)
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600),
                                        queue: DispatchQueue.main,
                                        using: { time in
            // ?
        })
        
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new ], context: nil)
        
        // TODO: error catch
        
        player?.play()
        
        stationSubject.send(station)
    }
    
    func stop() {
        player?.pause()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let statusRawValue = change?[.newKey] as? AVPlayer.TimeControlStatus.RawValue {
            let status = (statusRawValue == AVPlayer.TimeControlStatus.paused.rawValue ?
                          PlayerStatus.stopped :
                            PlayerStatus.playing)
            
            statusSubject.send(status)
        }
    }
}
