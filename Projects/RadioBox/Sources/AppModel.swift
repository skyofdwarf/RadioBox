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
    case start(UIWindow)
}

enum AppMutation {
}

enum AppEvent {
    case coordinate(AppCoordinator.Location)
}

struct AppState {
}

extension UIApplication {
    static let model = AppModel(coordinator: AppCoordinator())
    var model: AppModel { Self.model }
}

final class AppModel: ViewModel<AppAction, AppMutation, AppEvent, AppState> {
    let coordinator: AppCoordinator
    
    fileprivate init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        
        super.init(state: AppState(),
                   eventMiddlewares: [ coordinator.middleware() ])
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .start(let window):
            return .just(.event(.coordinate(.lookup(window))))
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
    }
}
