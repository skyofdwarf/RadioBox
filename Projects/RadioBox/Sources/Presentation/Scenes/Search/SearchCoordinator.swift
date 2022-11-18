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
    
    unowned let vc: SearchViewController
    
    init(vc: SearchViewController) {
        self.vc = vc
    }
    
    static func start() -> SearchViewController {
        let vc = SearchViewController()
        let coordinator = Self.init(vc: vc)
        let vm = SearchViewModel(coordinator: coordinator)
        
        vc.vm = vm
        
        return vc
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
