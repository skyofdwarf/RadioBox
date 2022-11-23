//
//  SettingsCoordinator.swift
//  RadioBox
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
    
    private(set) weak var vc: SettingsViewController?
    
    init(service: RadioService, player: Player) {
        self.service = service
        self.player = player
    }
    
    @discardableResult
    func start() -> VC {
        // just return vc instance
        SettingsViewController().then {
            self.vc = $0
            $0.vm = SettingsViewModel(coordinator: self)
        }
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
