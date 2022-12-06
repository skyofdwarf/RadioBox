//
//  SearchCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM

final class SearchCoordinator: Coordinator {
    enum Location {
        case station(RadioStation)
        case pop(UIViewController)
    }
    
    let service: RadioService
    let player: Player
    let favoritesService: FavoritesService
    
    private(set) weak var target: SearchViewController?
    
    init(service: RadioService, favoritesService: FavoritesService, player: Player) {
        self.service = service
        self.favoritesService = favoritesService
        self.player = player
    }
    
    func instantiateTarget() -> SearchViewController {
        SearchViewController().then {
            self.target = $0
            $0.vm = SearchViewModel(service: service, favoritesService: favoritesService, coordinator: self, player: player)
        }
    }
    
    @discardableResult
    func start() -> SearchViewController {
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
