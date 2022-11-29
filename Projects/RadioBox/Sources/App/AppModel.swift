//
//  AppModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum AppAction {
    case showPlayer(Player, from: UIViewController)
}

enum AppMutation {
}

enum AppEvent {
    case coordinate(AppCoordinator.Location)
}

extension AppEvent: Coordinating {
    var location: AppCoordinator.Location? {
        switch self {
        case .coordinate(let location):
            return location
        default: return nil
        }
    }
}

struct AppState {
}

final class AppModel: CoordinatingViewModel<AppAction, AppMutation, AppEvent, AppState> {
    let player: Player
    init<C: Coordinator>(coordinator: C, player: Player) where C.Location == Event.Location {
        self.player = player
        
        super.init(coordinator: coordinator, state: State())
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .showPlayer(let player, let vc):
            return .just(.event(.coordinate(.player(player, from: vc))))
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        }
    }
}
