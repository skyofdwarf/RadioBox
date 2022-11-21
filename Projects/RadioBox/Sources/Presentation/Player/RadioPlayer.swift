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
    enum PlayerError: Swift.Error {
        case invalidURL(String)
    }
    
    private let statusSubject = CurrentValueSubject<PlayerStatus, Never>(.disabled)
    var status: AnyPublisher<PlayerStatus, Never> { statusSubject.eraseToAnyPublisher() }
    
    private let stationSubject = CurrentValueSubject<RadioStation?, Never>(nil)
    var station: AnyPublisher<RadioStation?, Never> { stationSubject.eraseToAnyPublisher() }
    
    private let errorSubject = PassthroughSubject<Error, Never>()
    var error: AnyPublisher<Error, Never> { errorSubject.eraseToAnyPublisher() }
    
    private let streamTitleSubject = PassthroughSubject<String, Never>()
    var streamTitle: AnyPublisher<String, Never> { streamTitleSubject.eraseToAnyPublisher() }
    
    private let streamUrlSubject = PassthroughSubject<String, Never>()
    var streamUrl: AnyPublisher<String, Never> { streamUrlSubject.eraseToAnyPublisher() }
    
    private let player = AVPlayer()
    private var playerItem: AVPlayerItem?
    private var metadataOutput: AVPlayerItemMetadataOutput?
    
    deinit {
        player.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override init() {
        super.init()
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new ], context: nil)
    }
    
    static func configureAudioSession() {
        print("categories: \(AVAudioSession.sharedInstance().availableCategories)")
        print("modes: \(AVAudioSession.sharedInstance().availableModes)")
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            mode: .default,
                                                            options: [.interruptSpokenAudioAndMixWithOthers, .allowAirPlay])
        } catch {
            print("AudioSettion configuring error: \(error)")
        }
    }
    
    private func activeAudio(_ active: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(active,
                                                          options: active ? []: [.notifyOthersOnDeactivation])
        } catch {
            print("AudioSession activation error: \(error)")
            errorSubject.send(error)
        }
    }
    
    private func disposePlayerItem() {
        if let metadataOutput {
            metadataOutput.setDelegate(nil, queue: nil)
            playerItem?.remove(metadataOutput)
        }
        playerItem?.removeObserver(self, forKeyPath: "status")
        playerItem = nil
        
        player.pause()
        player.cancelPendingPrerolls()
    }
    
    func play(station: RadioStation) {
        // dispose old item
        disposePlayerItem()
        
        // set new item
        guard let url = URL(string: station.url_resolved) else {
            stationSubject.send(station)
            errorSubject.send(PlayerError.invalidURL(station.url_resolved))
            return
        }
        
        activeAudio(true)
        
        playerItem = AVPlayerItem(url: url)
        
        playerItem?.addObserver(self, forKeyPath: "status", options: [.initial, .new ], context: nil)
        
        metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil).then {
            $0.setDelegate(self, queue: .main)
            playerItem?.add($0)
        }
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        // publish new station
        stationSubject.send(station)
    }
    
    func stop() {
        player.pause()
        
        activeAudio(false)
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
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case "timeControlStatus":
            if let rawValue = change?[.newKey] as? AVPlayer.TimeControlStatus.RawValue {
                // ignore changes after an error of player item
                
                guard let playerItem else {
                    return
                }
                
                guard playerItem.error == nil else {
                    return ;
                }
                
                if let status = PlayerStatus(from: AVPlayer.TimeControlStatus(rawValue: rawValue)) {
                    statusSubject.send(status)
                }
            }
        case "status":
            guard let currentPlayerItem = playerItem,
                  let observedPlayerItem = object as? AVPlayerItem,
                    currentPlayerItem == observedPlayerItem
            else {
                return
            }
            
            if let rawValue = change?[.newKey] as? AVPlayerItem.Status.RawValue {
                let failed = rawValue == AVPlayerItem.Status.failed.rawValue
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

extension RadioPlayer: AVPlayerItemMetadataOutputPushDelegate {
    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        guard let group = groups.first,
              let item = group.items.first
        else {
            return
        }
        
        switch item.identifier {
        case AVMetadataIdentifier.icyMetadataStreamTitle:
            if let title = item.stringValue {
                streamTitleSubject.send(title)
            }
        case AVMetadataIdentifier.icyMetadataStreamURL:
            if let url = item.stringValue {
                streamUrlSubject.send(url)
            }
        default:
#if DEBUG
            print("metadata key: \(String(describing: item.key)), keySpace: \(String(describing: item.keySpace))")
            print("metadata id: \(String(describing: item.identifier)), value: \(String(describing: item.value))")
#endif
            break
        }
    }
}
