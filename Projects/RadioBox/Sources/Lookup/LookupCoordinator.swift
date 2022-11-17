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

    deinit {
        print("\(#file).\(#function)")
    }
    
    init(window: UIWindow, vc: LookupViewController) {
        self.window = window
        self.vc = vc
    }

    static func start(window: UIWindow) {
        let vc = LookupViewController()
        let coordinator = Self.init(window: window, vc: vc)
        let vm = LookupViewModel(coordinator: coordinator)

        vc.vm = vm
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .home(let hostname):
            if let url = URL(string: "https://\(hostname)") {
                MainCoordinator.start(window: window, serverURL: url)
            }
        }
    }
}
