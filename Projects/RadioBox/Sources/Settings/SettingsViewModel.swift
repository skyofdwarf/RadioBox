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

struct SettingsState {
    @Drived var fetching: Bool = false
}

final class SettingsViewModel: ViewModel<SettingsAction, SettingsMutation, SettingsEvent, SettingsState> {
    weak var coordinator: SettingsCoordinator?
        
    init(coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        
        super.init(state: State(),
                   eventMiddlewares: [Self.coordinating(coordinator)]
        )
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

extension SettingsViewModel {
    static func coordinating(_ coordinator: SettingsCoordinator) -> EventMiddleware {
        middleware.event { store, next, event in
            if case let .coordinate(location) = event {
                coordinator.coordinate(location)
            }
            return next(event)
        }
    }
}
