//
//  AppModel.swift
//  Radiow
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
    case checkAppUpdate
}

enum AppMutation {
    case appstoreAppVersion(AppVersion)
}

enum AppEvent {
    case coordinate(AppCoordinator.Location)
    case appUpdated(AppVersion)
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
    @Drived var installedAppVersion: AppVersion
    @Drived var appStoreAppVersion: AppVersion?
}

final class AppModel: CoordinatingViewModel<AppAction, AppMutation, AppEvent, AppState> {
    let player: Player
    let appUpdateChecker: AppUpdateChecker
    
    init<C: Coordinator>(coordinator: C, player: Player, appUpdateChecker: AppUpdateChecker) where C.Location == Event.Location {
        self.player = player
        self.appUpdateChecker = appUpdateChecker
        
        let state = State(installedAppVersion: AppVersion(value: UIApplication.shared.version))
        
        super.init(coordinator: coordinator, state: state)
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .showPlayer(let player, let vc):
            return .just(.event(.coordinate(.player(player, from: vc))))
        case .checkAppUpdate:
            return Observable<Reaction>.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                self.appUpdateChecker.check { appStoreVersion in
                    print("appStoreVersion: \(appStoreVersion)")
                    guard let appStoreVersion else {
                        observer.onCompleted()
                        return
                    }
                    
                    if appStoreVersion > state.installedAppVersion {
                        observer.onNext(.mutation(.appstoreAppVersion(appStoreVersion)))
                        observer.onNext(.event(.appUpdated(appStoreVersion)))
                    }
                    
                    observer.onCompleted()
                }
                
                return Disposables.create()
            }
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .appstoreAppVersion(let version):
            state.appStoreAppVersion = version
        }
    }
}
