//
//  App+Singleton.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/21.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import AVFAudio
import MediaPlayer

extension UIApplication {
    static let player = RadioPlayer()
    
    static let coordinator = AppCoordinator()
    static let model = AppModel(coordinator: coordinator, player: player, appUpdateChecker: AppStoreUpdateChecker())
    static let favoritesService = FavoritesService()
    
    var version: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0" }
    
    func start() -> UIWindow {
        configureAudioSession()
        configureRemoteCommandCenter()
        
        registerAudioIterruptionNotification()
        
        return UIApplication.coordinator.start()
    }
    
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch {
            print("AudioSettion configuring error: \(error)")
        }
    }
        
    func configureRemoteCommandCenter() {
        let center = MPRemoteCommandCenter.shared()
        
        center.playCommand.addTarget { _ in
            Self.player.toggle() ? .success : .commandFailed
        }
        
        center.pauseCommand.addTarget { _ in
            Self.player.toggle() ? .success : .commandFailed
        }
    }
    
    func registerAudioIterruptionNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAudioInterruptionNotification(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }
    
    @objc func handleAudioInterruptionNotification(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .ended:
            // Don't need to check AVAudioSession.InterruptionOptions.shouldResume
            Self.player.resume()
        default: break
        }
    }
}
