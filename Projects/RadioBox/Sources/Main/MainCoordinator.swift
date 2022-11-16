//
//  MainCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class MainCoordinator {
    static func start(window: UIWindow) {
        let vc = MainViewController().then {
            $0.viewControllers = [ HomeCoordinator.start(),
                                   SearchCoordinator.start(),
                                   SettingsCoordinator.start(),
            ].map { $0.navigationRooted }
        }

        window.rootViewController = vc
    }
}

extension UIViewController {
    var navigationRooted: UINavigationController { CustomNavigationController(rootViewController: self) }
}

class CustomNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
