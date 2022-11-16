//
//  HomeViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum HomeAction {
    case lookup
}

enum HomeMutation {
    case fetching(Bool)
    case hostnames([String])
}

enum HomeEvent {
    case coordinate(HomeCoordinator.Location)
    case lookupFailed
    case noHostname
}

struct HomeState {
    @Drived var fetching: Bool = false
    @Drived var hostnames: [String] = []
}

final class HomeViewModel: ViewModel<HomeAction, HomeMutation, HomeEvent, HomeState> {
    enum Constant {
        static let urlToLookup = "all.api.radio-browser.info"
    }
    
    weak var coordinator: HomeCoordinator?
        
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        
        super.init(state: HomeState(),
                   eventMiddlewares: [coordinator.middleware()]
        )
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .lookup:
            return Observable<Reaction>.create { observer in
                do {
                    let hostnames = try DNSLookup.reverseLookup(hostname: Constant.urlToLookup)
                    if hostnames.isEmpty {
                        observer.onNext(.event(.lookupFailed))
                    } else {
                        observer.onNext(.mutation(.hostnames(hostnames)))
                        let hostname = hostnames.randomElement()!
                        observer.onNext(.event(.coordinate(.home(hostname))))
                    }
                } catch {
                    observer.onNext(.event(.lookupFailed))
                }
                observer.onCompleted()
                return Disposables.create {}
            }
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .hostnames(let hostnames):
            state.hostnames = hostnames
        }
    }
}
