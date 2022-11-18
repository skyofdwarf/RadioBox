//
//  LookupCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class LookupCoordinator: Coordinator {
    enum Location {
        case home(String)
    }
    
    unowned let window: UIWindow
    unowned let vc: LookupViewController
    
    let player: Player

    deinit {
        print("\(#file).\(#function)")
    }
    
    init(window: UIWindow, vc: LookupViewController, player: Player) {
        self.window = window
        self.vc = vc
        self.player = player
    }

    static func start(window: UIWindow, player: Player) {
        let vc = LookupViewController()
        let coordinator = Self.init(window: window, vc: vc, player: player)
        let vm = LookupViewModel(coordinator: coordinator)

        vc.vm = vm
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .home(let hostname):
            if let url = URL(string: "https://\(hostname)") {
                MainCoordinator.start(window: window, serverURL: url, player: player)
            }
        }
    }
}
