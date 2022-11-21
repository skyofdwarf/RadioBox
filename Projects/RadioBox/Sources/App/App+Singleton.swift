//
//  App+Singleton.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/21.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

extension UIApplication {
    static let player = RadioPlayer()
    
    static let coordinator = AppCoordinator()
    static let model = AppModel(coordinator: coordinator, player: player)
    
    var window: UIWindow { Self.coordinator.window }
    
    func start() {
        UIApplication.model.send(action: .start)
    }
}
