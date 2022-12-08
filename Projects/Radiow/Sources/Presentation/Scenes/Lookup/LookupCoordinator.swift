//
//  LookupCoordinator.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class LookupCoordinator: Coordinator {
    enum Location {
        case home(String)
    }
    
    let window: UIWindow
    let player: Player
    let favoritesService: FavoritesService
    
    private(set) weak var target: LookupViewController?

    deinit {
        print("\(#file).\(#function)")
    }
    
    init(window: UIWindow, player: Player, favoritesService: FavoritesService) {
        self.window = window
        self.player = player
        self.favoritesService = favoritesService
    }
    
    func instantiateTarget() -> LookupViewController {
        LookupViewController().then {
            $0.vm = LookupViewModel(coordinator: self)
        }
    }

    @discardableResult
    func start() -> LookupViewController {
        instantiateTarget().then {
            self.target = $0
            
            window.rootViewController = $0
            window.makeKeyAndVisible()
        }
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .home(let hostname):
            if let url = URL(string: "https://\(hostname)") {
                MainCoordinator(window: window, serverURL: url, player: player, favoritesService: favoritesService).start()
            }
        }
    }
}
