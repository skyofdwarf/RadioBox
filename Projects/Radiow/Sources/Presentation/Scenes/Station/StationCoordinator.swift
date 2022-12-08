//
//  StationCoordinator.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/23.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM

final class StationCoordinator: Coordinator {
    enum Location {
    }
    
    let station: RadioStation
    let nc: UINavigationController?
    
    private(set) weak var target: StationViewController?
    
    deinit {
        print("\(#file).\(#function)")
    }
    
    init(station: RadioStation, nc: UINavigationController?) {
        self.station = station
        
        self.nc = nc
    }
    
    func instantiateTarget() -> StationViewController {
        StationViewController().then {
            $0.vm = StationViewModel(station: station,
                                     coordinator: self)
        }
    }
    
    @discardableResult
    func start() -> StationViewController {
        instantiateTarget().then {
            self.target = $0
            nc?.pushViewController($0, animated: true)
        }
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
