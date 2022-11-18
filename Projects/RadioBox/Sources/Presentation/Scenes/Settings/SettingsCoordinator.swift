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
    
    unowned let vc: SettingsViewController
    
    init(vc: SettingsViewController) {
        self.vc = vc
    }
    
    static func start() -> SettingsViewController {
        let vc = SettingsViewController()
        let coordinator = Self.init(vc: vc)
        let vm = SettingsViewModel(coordinator: coordinator)
        
        vc.vm = vm
        
        return vc
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
