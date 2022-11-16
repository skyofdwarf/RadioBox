//
//  HomeCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM

final class HomeCoordinator {
    enum Location {
        case home(String)
    }
    
    unowned let vc: HomeViewController
    
    init(vc: HomeViewController) {
        self.vc = vc
    }
    
    static func start() -> HomeViewController {
        let vc = HomeViewController()
        let c = Self.init(vc: vc)
        let vm = HomeViewModel(coordinator: c)
        
        vc.vm = vm
        
        return vc
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .home(let hostname):
            //MainCoordinator(window: window).start()
            return
        }
    }
    
    func middleware() -> HomeViewModel.EventMiddleware {
        HomeViewModel.middleware.event { [weak self] store, next, event in
            if case let .coordinate(location) = event {
                self?.coordinate(location)
            }
            
            return next(event)
        }
    }
}
