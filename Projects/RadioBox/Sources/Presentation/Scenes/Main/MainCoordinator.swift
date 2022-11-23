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
        
        let vc = MainViewController().then {
            $0.viewControllers = [ HomeCoordinator(service: service, player: player).start(),
                                   SearchCoordinator(service: service, player: player).start(),
                                   SettingsCoordinator(service: service, player: player).start(),
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
