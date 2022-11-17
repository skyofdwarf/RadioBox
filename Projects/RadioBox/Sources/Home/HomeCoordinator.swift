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
    
    unowned let vc: HomeViewController
    
    init(vc: HomeViewController) {
        self.vc = vc
    }
    
    static func start(service: RadioService) -> HomeViewController {
        let vc = HomeViewController()
        let coordinator = Self.init(vc: vc)
        let vm = HomeViewModel(service: service, coordinator: coordinator)
        
        vc.vm = vm
        
        return vc
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
