//
//  UINavigationController+Util.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/24.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

extension UIViewController {
//    var navigationRooted: UINavigationController { CustomNavigationController(rootViewController: self) }
    
    var navigationRooted: UINavigationController {
        let nc = CustomNavigationController(navigationBarClass: nil, toolbarClass: PlayerBar.self)
        nc.viewControllers = [ self ]
        nc.isToolbarHidden = false
        
        if let playerBar = navigationController?.toolbar as? PlayerBar {
            playerBar.bind(player: UIApplication.player)
        }
        
        // ensure toolbar is visible even on scroll edge
        if #available(iOS 15.0, *) {
            nc.toolbar.scrollEdgeAppearance = nc.toolbar.standardAppearance
        }
        
        return nc
    }
}
