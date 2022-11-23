//
//  HomeCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM

final class HomeCoordinator: Coordinator {
    enum Location {
    }
    
    let service: RadioService
    let player: Player
    
    private(set) weak var target: HomeViewController?
    
    init(service: RadioService, player: Player) {
        self.service = service
        self.player = player
    }
    
    func instantiateTarget() -> HomeViewController {
        HomeViewController().then {
            self.target = $0
            $0.vm = HomeViewModel(service: service, coordinator: self, player: player)
        }
    }
    
    @discardableResult
    func start() -> HomeViewController {
        // just return vc instance
        instantiateTarget()
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
