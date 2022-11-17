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

extension SearchEvent: Coordinating {
    var location: SearchCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct SearchState {
    @Drived var fetching: Bool = false
}

final class SearchViewModel: CoordinatingViewModel<SearchAction, SearchMutation, SearchEvent, SearchState> {
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
