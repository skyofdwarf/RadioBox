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
        case lookup(Player)
    }
    
    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    var vc: UIViewController? { window.rootViewController }
    
    func coordinate(_ location: Location) {
        switch location {
        case .lookup(let player):
            LookupCoordinator.start(window: window, player: player)
        }
    }
    
    func start() {
        UIApplication.model.send(action: .start)
    }
}
