//
//  FavoritesCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/12/01.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM

final class FavoritesCoordinator: Coordinator {
    enum Location {
        case station(RadioStation)
        case pop(UIViewController)
    }
    
    let service: RadioService
    let player: Player
    
    private(set) weak var target: FavoritesViewController?
    
    init(service: RadioService, player: Player) {
        self.service = service
        self.player = player
    }
    
    func instantiateTarget() -> FavoritesViewController {
        FavoritesViewController().then {
            self.target = $0
            $0.vm = FavoritesViewModel(service: service, coordinator: self, player: player)
        }
    }
    
    @discardableResult
    func start() -> FavoritesViewController {
        // just return vc instance
        instantiateTarget()
    }
    
    func coordinate(_ location: Location) {
        switch location {
        case .station(let station):
            createStationCoordinator(with: station).start()
        case .pop(let vc):
            target?.present(vc, animated: true)
        }
    }
}
