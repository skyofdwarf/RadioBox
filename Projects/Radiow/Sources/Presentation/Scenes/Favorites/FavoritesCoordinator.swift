//
//  FavoritesCoordinator.swift
//  Radiow
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
    let favoritesService: FavoritesService
    let player: Player
    
    private(set) weak var target: FavoritesViewController?
    
    init(service: RadioService, favoritesService: FavoritesService, player: Player) {
        self.service = service
        self.favoritesService = favoritesService
        self.player = player
    }
    
    func instantiateTarget() -> FavoritesViewController {
        FavoritesViewController().then {
            self.target = $0
            $0.vm = FavoritesViewModel(service: service, favoritesService: favoritesService, coordinator: self, player: player)
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
            guard let stationVC = vc as? StationViewController else { return }
            target?.navigationController?.pushViewController(stationVC, animated: true)
        }
    }
}
