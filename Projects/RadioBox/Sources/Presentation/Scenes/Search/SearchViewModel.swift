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
    case search(String)
    case trySearchNextPage
}

enum SearchMutation {
    case fetching(Bool)
    case stations([RadioStation], reset: Bool)
    
    case keyword(String?)
    case page(Int)
    case hasNextPage(Bool)
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
    @Drived var stations: [RadioStation] = []
    
    var keyword: String?
    var page = 0
    var hasNextPage = true
}

final class SearchViewModel: CoordinatingViewModel<SearchAction, SearchMutation, SearchEvent, SearchState> {
    let service: RadioService
    let player: Player
    
    init<C: Coordinator>(service: RadioService, coordinator: C, player: Player) where C.Location == Event.Location {
        self.service = service
        self.player = player
        
        super.init(coordinator: coordinator, state: State())
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .search(let keyword):
            return searchKeyword(keyword, page: 0)
        case .trySearchNextPage:
            return searchKeyword(state.keyword, page: state.page + 1)
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .stations(let stations, let reset):
            if reset {
                state.stations = stations
            } else {
                state.stations += stations
            }
        case .page(let page):
            state.page = page
        case .hasNextPage(let hasNextPage):
            state.hasNextPage = hasNextPage
        case .keyword(let keyword):
            state.keyword = keyword
        }
    }
}

extension SearchViewModel {
    enum Constant {
        static let PageLimit = 30
    }
    
    func searchKeyword(_ keyword: String?, page: Int) -> Observable<Reaction> {
        guard let keyword, !state.fetching, state.hasNextPage else {
            return .empty()
        }
        let limit = Constant.PageLimit
        let offset = page * limit
        
        return Observable<Reaction>.create { [weak self] observer in
            let options: [SearchStationOptions] = [.name(keyword),
                                                   .offset(offset),
                                                   .limit(limit) ]
            self?.service.request(RadioBrowserTarget.searchStation(options), success: { (stationDTOs: [RadioBrowserStation]) in
                let hasNextPage = stationDTOs.count >= Constant.PageLimit
                let stations = stationDTOs.map(RadioStation.init(_:))
                observer.onNext(.mutation(.page(page)))
                observer.onNext(.mutation(.hasNextPage(hasNextPage)))
                observer.onNext(.mutation(.stations(stations, reset: offset == 0)))
                observer.onCompleted()
            }, failure: {
                observer.onNext(.error($0))
                observer.onCompleted()
            })
            return Disposables.create()
        }
        .startWith(.mutation(.fetching(true)), .mutation(.keyword(keyword)))
        .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
    }
}
