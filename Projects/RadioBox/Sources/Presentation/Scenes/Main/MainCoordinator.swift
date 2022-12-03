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
    
    init(window: UIWindow, serverURL: URL, player: Player) {
        self.window = window
        self.serverURL = serverURL
        self.player = player
    }
    
    func instantiateTarget() -> MainViewController {
        let service = RadioService(baseURL: serverURL)
        
        return MainViewController(coordinator: self).then {
            $0.viewControllers = [ HomeCoordinator(service: service, player: player).start(),
                                   SearchCoordinator(service: service, player: player).start(),
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
