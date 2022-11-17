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
    case hostname(String)
}

enum AppEvent {
    case coordinate(AppCoordinator.Location)
}

struct PlayContext {
    var station: RadioBrowserStation
    var cover: String?
    var title: String?
}

struct AppState {
    var hostname: String?
    
    var playing = false
    var playContext: PlayContext?
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
        switch mutation {
        case .hostname(let hostname):
            state.hostname = hostname
        }
    }
}
