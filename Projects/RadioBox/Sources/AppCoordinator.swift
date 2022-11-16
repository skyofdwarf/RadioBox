//
//  AppCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class AppCoordinator {
    enum Location {
        case lookup(UIWindow)
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .lookup(let window):
            LookupCoordinator.start(window: window)
        }
    }
    
    func middleware() -> AppModel.EventMiddleware {
        AppModel.middleware.event { [weak self] store, next, event in
            if case let .coordinate(location) = event {
                self?.coordinate(location)
            }
            
            return next(event)
        }
    }
}
