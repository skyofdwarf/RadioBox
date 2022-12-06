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
        case station(RadioStation)
        case pop(UIViewController)
    }
    
    let service: RadioService
    let favoritesService: FavoritesService
    let player: Player
    
    private(set) weak var target: HomeViewController?
    
    init(service: RadioService, favoritesService: FavoritesService, player: Player) {
        self.service = service
        self.favoritesService = favoritesService
        self.player = player
    }
    
    func instantiateTarget() -> HomeViewController {
        HomeViewController().then {
            self.target = $0
            $0.vm = HomeViewModel(service: service, favoritesService: favoritesService, coordinator: self, player: player)
        }
    }
    
    @discardableResult
    func start() -> HomeViewController {
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

extension Coordinator where Target: UIViewController {
    func contextMenu(for station: RadioStation) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: station.stationuuid as NSString,
                                   previewProvider: { [weak self] () -> UIViewController? in
            guard let self else { return nil }

            return self.createStationCoordinator(with: station).instantiateTarget()
        }, actionProvider: nil)
    }
    
    func createStationCoordinator(with station: RadioStation) -> StationCoordinator {
        StationCoordinator(station: station,
                           nc: target?.navigationController)
    }
}
