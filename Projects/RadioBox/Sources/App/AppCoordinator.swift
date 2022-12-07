//
//  AppCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator {
    enum Location {
        case player(Player, from: UIViewController)
    }
    
    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    
    var target: UIWindow? { window }
    var rootViewController: UIViewController? { window.rootViewController }
    
    func coordinate(_ location: Location) {
        switch location {
        case .player(let player, let vc):
            PlayerCoordinator(from: vc, player: player).start()
        }
    }
    
    func instantiateTarget() -> UIWindow {
        window
    }
    
    @discardableResult
    func start() -> UIWindow {
        LookupCoordinator(window: window, player: UIApplication.player, favoritesService: UIApplication.favoritesService).start()
        return window
    }
}
