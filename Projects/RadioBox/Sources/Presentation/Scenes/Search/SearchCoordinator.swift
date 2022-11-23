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
    }
    
    let service: RadioService
    let player: Player
    
    private(set) weak var vc: SearchViewController?
    
    init(service: RadioService, player: Player) {
        self.service = service
        self.player = player
    }
    
    @discardableResult
    func start() -> VC {
        // just return vc instance
        SearchViewController().then {
            self.vc = $0
            $0.vm = SearchViewModel(service: service, coordinator: self, player: player)
        }
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
