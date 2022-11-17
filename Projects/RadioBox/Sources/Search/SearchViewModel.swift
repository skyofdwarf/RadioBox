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

enum SearchAction {
}

enum SearchMutation {
    case fetching(Bool)
}

enum SearchEvent {
    case coordinate(SearchCoordinator.Location)
}

struct SearchState {
    @Drived var fetching: Bool = false
}

final class SearchViewModel: ViewModel<SearchAction, SearchMutation, SearchEvent, SearchState> {
    weak var coordinator: SearchCoordinator?
        
    init(coordinator: SearchCoordinator) {
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

extension SearchViewModel {
    static func coordinating(_ coordinator: SearchCoordinator) -> EventMiddleware {
        middleware.event { store, next, event in
            if case let .coordinate(location) = event {
                coordinator.coordinate(location)
            }
            return next(event)
        }
    }
}
