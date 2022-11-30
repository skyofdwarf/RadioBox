//
//  MainCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RxCocoa

final class MainCoordinator {
    static func start(window: UIWindow, serverURL: URL, player: Player) {
        let service = RadioService(baseURL: serverURL)
        
        let mockService = RadioService.mock.delayedStub(baseURL: serverURL, seconds: 1)
        
        let vc = MainViewController().then {
            $0.viewControllers = [ HomeCoordinator(service: mockService, player: player).start(),
                                   SearchCoordinator(service: mockService, player: player).start(),
                                   SettingsCoordinator(service: mockService, player: player).start(),
            ].map { $0.navigationRooted }
        }

        window.rootViewController = vc
    }
}
