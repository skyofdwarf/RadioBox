//
//  LookupViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum LookupAction {
    case lookup
}

enum LookupMutation {
    case fetching(Bool)
    case hostnames([String])
}

enum LookupEvent {
    case coordinate(LookupCoordinator.Location)
    case lookupFailed
    case noHostname
}

struct LookupState {
    @Drived var fetching: Bool = false
    @Drived var hostnames: [String] = []
}

final class LookupViewModel: ViewModel<LookupAction, LookupMutation, LookupEvent, LookupState> {
    enum Constant {
        static let urlToLookup = "all.api.radio-browser.info"
    }
    
    let coordinator: LookupCoordinator
    
    deinit {
        print("\(#file).\(#function)")
    }
    
    init(coordinator: LookupCoordinator) {
        self.coordinator = coordinator
        
        super.init(state: LookupState(),
                   eventMiddlewares: [Self.coordinating(coordinator)]
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
            .startWith(.mutation(.fetching(true)))
            .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
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

extension LookupViewModel {
    static func coordinating(_ coordinator: LookupCoordinator) -> EventMiddleware {
        middleware.event { store, next, event in
            if case let .coordinate(location) = event {
                coordinator.coordinate(location)
            }
            return next(event)
        }
    }
}
