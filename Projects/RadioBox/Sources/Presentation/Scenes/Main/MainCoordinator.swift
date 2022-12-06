//
//  MainCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RxCocoa

final class MainCoordinator: Coordinator {
    enum Location {
        case home(String)
    }
    
    private(set) weak var target: MainViewController?
    
    let window: UIWindow
    let serverURL: URL
    let player: Player
    let favoritesService: FavoritesService
    
    init(window: UIWindow, serverURL: URL, player: Player, favoritesService: FavoritesService) {
        self.window = window
        self.serverURL = serverURL
        self.player = player
        self.favoritesService = favoritesService
    }
    
    func instantiateTarget() -> MainViewController {
        let service = RadioService(baseURL: serverURL)
        
        return MainViewController(coordinator: self).then {
            $0.viewControllers = [ HomeCoordinator(service: service, favoritesService: favoritesService, player: player).start(),
                                   SearchCoordinator(service: service, player: player).start(),
                                   FavoritesCoordinator(service: service, favoritesService: favoritesService, player: player).start(),
                                   SettingsCoordinator(service: service, player: player).start(),
            ].map { $0.navigationRooted }
        }
    }
    
    @discardableResult
    func start() -> MainViewController {
        instantiateTarget().then {
            window.rootViewController = $0
        }
    }
}
