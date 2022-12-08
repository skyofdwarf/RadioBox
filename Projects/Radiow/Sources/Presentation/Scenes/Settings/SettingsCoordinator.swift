//
//  SettingsCoordinator.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class SettingsCoordinator: Coordinator {
    enum Location {
    }
    
    let service: RadioService
    let player: Player
    
    private(set) weak var target: SettingsViewController?
    
    init(service: RadioService, player: Player) {
        self.service = service
        self.player = player
    }
    
    func instantiateTarget() -> SettingsViewController {
        SettingsViewController().then {
            self.target = $0
            $0.vm = SettingsViewModel(coordinator: self)
        }
    }
    
    @discardableResult
    func start() -> SettingsViewController {
        // just return vc instance
        instantiateTarget()
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
