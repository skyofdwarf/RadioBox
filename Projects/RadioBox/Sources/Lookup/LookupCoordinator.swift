//
//  LookupCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class LookupCoordinator {
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
        let c = Self.init(window: window, vc: vc)
        let vm = LookupViewModel(coordinator: c)

        vc.vm = vm
        
        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .home(let hostname):
            MainCoordinator.start(window: window)
        }
    }
    
    func middleware() -> LookupViewModel.EventMiddleware {
        LookupViewModel.middleware.event { [weak self] store, next, event in
            if case let .coordinate(location) = event {
                self?.coordinate(location)
            }
            
            return next(event)
        }
    }
}
