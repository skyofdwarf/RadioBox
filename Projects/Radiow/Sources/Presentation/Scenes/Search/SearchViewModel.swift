//
//  HomeViewModel.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum SearchAction {
    case play(RadioStation)
    case search(String)
    case trySearchNextPage
    case toggleFavorites(RadioStation)
}

enum SearchMutation {
    case fetching(Bool)
    case stations([RadioStation], reset: Bool)
    
    case keyword(String?)
    case page(Int)
    case hasNextPage(Bool)
    case updateStation(RadioStation)
}

enum SearchEvent {
    case coordinate(SearchCoordinator.Location)
    case scrollToTop
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
    let favoritesService: FavoritesService
    let player: Player
    
    init<C: Coordinator>(service: RadioService, favoritesService: FavoritesService, coordinator: C, player: Player) where C.Location == Event.Location {
        self.service = service
        self.favoritesService = favoritesService
        self.player = player
        
        super.init(coordinator: coordinator, state: State())
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .play(let station):
            player.play(station: station)
            return clickStation(station)
        case .search(let keyword):
            return searchKeyword(keyword, page: 0)
        case .trySearchNextPage:
            return searchKeyword(state.keyword, page: state.page + 1)
        case .toggleFavorites(let station):
            return toggleFavorites(station)
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
                let orderedSet = NSMutableOrderedSet(array: state.stations)
                orderedSet.addObjects(from: stations)
                
                state.stations = orderedSet.array as! [RadioStation]
            }
        case .page(let page):
            state.page = page
        case .hasNextPage(let hasNextPage):
            state.hasNextPage = hasNextPage
        case .keyword(let keyword):
            state.keyword = keyword
        case .updateStation(let station):
            for i in 0..<state.stations.count {
                if state.stations[i].stationuuid == station.stationuuid {
                    state.stations[i] = station
                    break
                }
            }
        }
    }
    
    override func transform(mutation: Observable<SearchMutation>) -> Observable<SearchMutation> {
        let changes = favoritesService.changes
            .asObservable()
            .flatMap({ changes -> Observable<SearchMutation> in
                switch changes {
                case .added(let station), .removed(let station):
                    return .just(.updateStation(station))
                }
            })
        
        return .merge(mutation, changes)
    }
}

extension SearchViewModel {
    enum Constant {
        static let PageLimit = 30
    }
    
    func clickStation(_ station: RadioStation) -> Observable<Reaction> {
        service.request(RadioBrowserTarget.clickStation(station.stationuuid)) { _ in }
        return .empty()
    }
    
    func searchKeyword(_ keyword: String?, page: Int) -> Observable<Reaction> {
        guard let keyword, !state.fetching, (page == 0 || state.hasNextPage) else {
            return .empty()
        }
        let limit = Constant.PageLimit
        let offset = page * limit
        
        return Observable<Reaction>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let options: [SearchStationOptions] = [.name(keyword),
                                                   .offset(offset),
                                                   .order(.votes),
                                                   .hidebroken(true),
                                                   .limit(limit) ]
            self.service.request(RadioBrowserTarget.searchStation(options), success: { [weak self] (stationDTOs: [RadioBrowserStation]) in
                guard let self else {
                    observer.onCompleted()
                    return
                }
                
                let hasNextPage = stationDTOs.count >= Constant.PageLimit
                var stations = stationDTOs.map(RadioStation.init(_:))
                let scrollToTop = !stations.isEmpty && page == 0
                let uuids = stations.map(\.stationuuid)
                let favorites = self.favoritesService.filterContained(uuids)
                
                for i in 0..<stations.count {
                    stations[i].favorited = favorites.contains(stations[i].stationuuid)
                }
                
                observer.onNext(.mutation(.stations(stations, reset: offset == 0)))
                observer.onNext(.mutation(.page(page)))
                observer.onNext(.mutation(.hasNextPage(hasNextPage)))
                
                if scrollToTop {
                    observer.onNext(.event(.scrollToTop))
                }
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
    
    func toggleFavorites(_ station: RadioStation) -> Observable<Reaction> {
        guard favoritesService.available, !state.fetching else {
            return .empty()
        }
        return Observable<Reaction>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            var success = false
            var station = station
            
            station.favorited = !station.favorited
            
            if station.favorited {
                success = self.favoritesService.add(station)
            } else {
                success = self.favoritesService.remove(station)
            }
            
            if success {
                observer.onNext(.mutation(.updateStation(station)))
            }
            
            observer.onCompleted()
            
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .observe(on: MainScheduler.instance)
        .startWith(.mutation(.fetching(true)))
        .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
    }
}
