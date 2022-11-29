//
//  PlayerViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/28.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift
import RxCocoa
import Combine
import Moya

enum PlayerAction {
}

enum PlayerMutation {
}

enum PlayerEvent {
    case coordinate(PlayerCoordinator.Location)
}

extension PlayerEvent: Coordinating {
    var location: PlayerCoordinator.Location? {
        switch self {
        }
    }
}

struct PlayerState {
}

final class PlayerViewModel: CoordinatingViewModel<PlayerAction, PlayerMutation, PlayerEvent, PlayerState> {
    let player: Player
        
    init<C: Coordinator>(coordinator: C, player: Player) where C.Location == Event.Location {
        self.player = player
        
        super.init(coordinator: coordinator,
                   state: State()
        )
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        }
    }
        
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        }
    }
}
