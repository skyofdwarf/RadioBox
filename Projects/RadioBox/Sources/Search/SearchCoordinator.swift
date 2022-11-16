//
//  SearchCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

final class SearchCoordinator {
    enum Location {
        case home(String)
    }
    
    unowned let vc: SearchViewController
    
    init(vc: SearchViewController) {
        self.vc = vc
    }
    
    static func start() -> SearchViewController {
        let vc = SearchViewController()
        let c = Self.init(vc: vc)
        let vm = SearchViewModel(coordinator: c)
        
        vc.vm = vm
        
        return vc
    }
}
