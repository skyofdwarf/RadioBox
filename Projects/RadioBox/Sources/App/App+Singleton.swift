//
//  App+Singleton.swift
//  RadioBox
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
    static let model = AppModel(coordinator: coordinator, player: player)
    
    func start() -> UIWindow {
        configureAudioSession()
        configureRemoteCommandCenter()
        
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
}
