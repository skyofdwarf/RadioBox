//
//  SettingsViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum SettingsAction {
}

enum SettingsMutation {
    case fetching(Bool)
}
enum SettingsEvent {
    case coordinate(SettingsCoordinator.Location)
}

extension SettingsEvent: Coordinating {
    var location: SettingsCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct SettingsState {
    @Drived var fetching: Bool = false
}

final class SettingsViewModel: CoordinatingViewModel<SettingsAction, SettingsMutation, SettingsEvent, SettingsState> {
    init<C: Coordinator>(coordinator: C) where C.Location == Event.Location {
        super.init(coordinator: coordinator, state: State())
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        }
    }
}