//
//  MainViewModel.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/12/08.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift
import RxCocoa

enum MainAction {
    case goToAppstore
}

enum MainMutation {
}

enum MainEvent {
    case coordinate(MainCoordinator.Location)
    case appEvent(AppEvent)
}

extension MainEvent: Coordinating {
    var location: MainCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct MainState {
}

final class MainViewModel: CoordinatingViewModel<MainAction, MainMutation, MainEvent, MainState> {
    let appModel: AppModel
    
    init<C: Coordinator>(appModel: AppModel, coordinator: C) where C.Location == Event.Location {
        self.appModel = appModel
        
        let state = State()
        
        super.init(coordinator: coordinator, state: state)
        
        appModel.send(action: .checkAppUpdate)
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .goToAppstore:
            return .just(.event(.coordinate(.appstore)))
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        }
    }
        
    override func transform(event: Observable<MainEvent>) -> Observable<MainEvent> {
        let appUpdated = appModel.event
            .asObservable()
            .map { MainEvent.appEvent($0) }
        
        return .merge(event, appUpdated)
    }
}
