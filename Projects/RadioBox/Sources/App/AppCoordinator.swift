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
    }
    
    let window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    
    var target: UIWindow? { window }
    var vc: UIViewController? { window.rootViewController }
    
    func coordinate(_ location: Location) {
    }
    
    func instantiateTarget() -> UIWindow {
        window
    }
    
    @discardableResult
    func start() -> UIWindow {
        LookupCoordinator(window: window, player: UIApplication.player).start()
        return window
    }
}
