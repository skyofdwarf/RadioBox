//
//  UINavigationController+Util.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/24.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import AVKit

extension UIViewController {
    var navigationRooted: UINavigationController {
        let nc = CustomNavigationController(navigationBarClass: nil, toolbarClass: PlayerBar.self)
        nc.viewControllers = [ self ]
        nc.isToolbarHidden = false
        
        if let playerBar = navigationController?.toolbar as? PlayerBar {
            playerBar.bind(player: UIApplication.player)
                
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(playerBarDidTap(_:)))
            playerBar.addGestureRecognizer(tap)
        }
        
        // ensure toolbar is visible even on scroll edge
        if #available(iOS 15.0, *) {
            nc.toolbar.scrollEdgeAppearance = nc.toolbar.standardAppearance
        }
        
        return nc
    }
    
    @objc func playerBarDidTap(_ recognizer: UITapGestureRecognizer) {
        guard let playerBar = navigationController?.toolbar as? PlayerBar,
              let player = playerBar.player
        else { return }
        
        UIApplication.model.send(action: .showPlayer(player, from: self))
    }
}
