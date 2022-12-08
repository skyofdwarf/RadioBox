//
//  RadioPlayer.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/18.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer
import Kingfisher

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
    
    private let streamTitleSubject = CurrentValueSubject<(title: String, artist: String?), Never>(("", nil))
    var streamTitle: AnyPublisher<(title: String, artist: String?), Never> { streamTitleSubject.eraseToAnyPublisher() }
    
    private let streamArtworkSubject = CurrentValueSubject<URL?, Never>(nil)
    var streamArtwork: AnyPublisher<URL?, Never> { streamArtworkSubject.eraseToAnyPublisher() }
    
    private let player = AVPlayer()
    private var playerItem: AVPlayerItem?
    private var metadataOutput: AVPlayerItemMetadataOutput?
    
    private var playTarget: Any?
    private var pauseTarget: Any?
    
    var isPlaying: Bool { player.timeControlStatus == .playing || player.timeControlStatus == .waitingToPlayAtSpecifiedRate }
    
    deinit {
        player.removeObserver(self, forKeyPath: "timeControlStatus")
        
        if let playTarget {
            MPRemoteCommandCenter.shared().playCommand.removeTarget(playTarget)
        }
        if let pauseTarget {
            MPRemoteCommandCenter.shared().pauseCommand.removeTarget(pauseTarget)
        }
    }
    
    override init() {
        super.init()
        
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.initial, .new ], context: nil)
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
        if stationSubject.value?.stationuuid == station.stationuuid {
            if !isPlaying {
                player.play()
            }
            return
        }
        
        // dispose old item
        disposePlayerItem()
        
        // set new item
        guard let url = URL(string: station.url) else {
            stationSubject.send(station)
            errorSubject.send(PlayerError.invalidURL(station.url))
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
        streamTitleSubject.send((station.name, nil))
        streamArtworkSubject.send(nil)
        stationSubject.send(station)
        
        updatePlayingInfo(station: station)
        parseStreamUrl(station.favicon)
    }
    
    func resume() {
        if !isPlaying {
            player.play()
        }
    }
    
    func stop() {
        player.pause()
        
        activeAudio(false)
    }
    
    @discardableResult
    func toggle() -> Bool {
        guard player.currentItem != nil else { return false }
        
        switch player.timeControlStatus {
        case .playing, .waitingToPlayAtSpecifiedRate:
            player.pause()
            return true
        case .paused:
            player.play()
            return true
        default:
            return false
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

// MARK: - Metadata

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
                print("StreamTitle: \(title)")
                parseStreamTitle(title)
            }
        case AVMetadataIdentifier.icyMetadataStreamURL:
            print("StreamUrl.value: \(item.value)")
            if let url = item.stringValue {
                print("StreamUrl: \(url)")
                parseStreamUrl(url)
            }
        default:
#if DEBUG
            print("metadata key: \(String(describing: item.key)), keySpace: \(String(describing: item.keySpace))")
            print("metadata id: \(String(describing: item.identifier)), value: \(String(describing: item.value))")
#endif
            break
        }
    }
    
    private func parseStreamTitle(_ title: String) {
        let tokens = title.split(separator: "-")
        
        var songTitle: String = title
        var artist: String?
        
        if tokens.count > 1 {
            songTitle = String(tokens[1]).trimmingCharacters(in: CharacterSet.whitespaces)
            artist = String(tokens[0]).trimmingCharacters(in: CharacterSet.whitespaces)
        }

        streamTitleSubject.send((title: songTitle, artist: artist))
        updatePlayingInfo(title: songTitle, artist: artist)
    }
    
    private func parseStreamUrl(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let cacheKey = url.absoluteString
        
        let isCached = ImageCache.default.isCached(forKey: cacheKey)
        
        if isCached {
            ImageCache.default.retrieveImage(forKey: cacheKey) { [weak self] result in
                switch result {
                case .success(let value):
                    guard let image = value.image else { return }
                    
                    self?.updatePlayingInfo(artwork: image)
                    self?.streamArtworkSubject.send(url)
                case .failure(let error):
                    print(error)
                    break
                }
            }
        } else {
            ImageDownloader.default.downloadImage(with: url) { [weak self] result in
                switch result {
                case .success(let value):
                    ImageCache.default.store(value.image, forKey: url.absoluteString)
                    
                    self?.updatePlayingInfo(artwork: value.image)
                    self?.streamArtworkSubject.send(url)
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
}

// MARK: - AudioSession

extension RadioPlayer {
    private func activeAudio(_ active: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(active)
        } catch {
            print("AudioSession activation error: \(error)")
            errorSubject.send(error)
        }
    }
}

// MARK: - MediaPlayer

private extension RadioPlayer {
    func updatePlayingInfo(station: RadioStation) {
        var playingInfo: [String: Any] = [:]
        
        playingInfo[MPMediaItemPropertyTitle] = station.name
        
        playingInfo[MPNowPlayingInfoPropertyIsLiveStream] = 1.0
        playingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        playingInfo[MPNowPlayingInfoPropertyAssetURL] = URL(string: station.url)
        
        playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 1.0
        playingInfo[MPMediaItemPropertyPlaybackDuration] = 1.0
        playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    func updatePlayingInfo(title: String, artist: String?) {
        var playingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        ?? [MPNowPlayingInfoPropertyIsLiveStream: 1.0,
               MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue ]
        
        playingInfo[MPMediaItemPropertyTitle] = title
        
        if let artist {
            playingInfo[MPMediaItemPropertyArtist] = artist
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
    func updatePlayingInfo(artwork: UIImage) {
        var playingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        ?? [MPNowPlayingInfoPropertyIsLiveStream: 1.0,
               MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue ]
        
        playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { size in
            return artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
}
