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
    
    let window: UIWindow
    let player: Player
    
    private(set) weak var vc: LookupViewController?

    deinit {
        print("\(#file).\(#function)")
    }
    
    init(window: UIWindow, player: Player) {
        self.window = window
        self.player = player
    }

    @discardableResult
    func start() -> UIViewController {
        LookupViewController().then {
            self.vc = $0
            
            $0.vm = LookupViewModel(coordinator: self)
            
            window.rootViewController = $0
            window.makeKeyAndVisible()
        }
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
