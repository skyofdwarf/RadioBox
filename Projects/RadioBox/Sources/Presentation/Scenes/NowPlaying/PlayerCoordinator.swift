//
//  PlayerCoordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/28.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM

final class PlayerCoordinator: Coordinator {
    enum Location {
    }
    
    let from: UIViewController?
    let player: Player
    
    var target: PlayerViewController?
    
    deinit {
        print("\(#file).\(#function)")
    }
    
    init(from: UIViewController?, player: Player) {
        self.from = from
        self.player = player
    }
        
    func instantiateTarget() -> PlayerViewController {
        PlayerViewController().then {
            $0.vm = PlayerViewModel(coordinator: self,
                                    player: player)
        }
    }
    
    @discardableResult
    func start() -> PlayerViewController {
        instantiateTarget().then {
            target = $0
            from?.present($0, animated: true)
        }
    }
    
    func coordinate(_ location: Location) {
        switch location {
        }
    }
}
