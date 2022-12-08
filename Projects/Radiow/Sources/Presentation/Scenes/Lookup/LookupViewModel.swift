//
//  LookupViewModel.swift
//  Radiow
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
    case status(LookupStatus)
    case hostnames([String])
}

enum LookupEvent {
    case coordinate(LookupCoordinator.Location)
    case lookupFailed
}

extension LookupEvent: Coordinating {
    var location: LookupCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct LookupState {
    @Drived var fetching: Bool = false
    @Drived var hostnames: [String] = []
    @Drived var status: LookupStatus = .idle
}

enum LookupStatus {
    case idle
    case lookingUp
    case lookedUp
    case failed
}

final class LookupViewModel: CoordinatingViewModel<LookupAction, LookupMutation, LookupEvent, LookupState> {
    enum Constant {
        static let urlToLookup = "all.api.radio-browser.info"
    }
    
    init<C: Coordinator>(coordinator: C) where C.Location == Event.Location {
        super.init(coordinator: coordinator, state: State())
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .lookup:
            return Observable<Reaction>.create { observer in
                do {
                    let hostnames = try DNSLookup.reverseLookup(hostname: Constant.urlToLookup)
                    if hostnames.isEmpty {
                        observer.onNext(.mutation(.status(.failed)))
                        observer.onNext(.event(.lookupFailed))
                    } else {
                        observer.onNext(.mutation(.hostnames(hostnames)))
                        observer.onNext(.mutation(.status(.lookedUp)))
                        let hostname = hostnames.randomElement()!
                        observer.onNext(.event(.coordinate(.home(hostname))))
                    }
                } catch {
                    observer.onNext(.mutation(.status(.failed)))
                    observer.onNext(.event(.lookupFailed))
                }
                observer.onCompleted()
                return Disposables.create {}
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .startWith(.mutation(.fetching(true)), .mutation(.status(.lookingUp)))
            .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .hostnames(let hostnames):
            state.hostnames = hostnames
        case .status(let status):
            state.status = status
        }
    }
}
