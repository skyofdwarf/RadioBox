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
import RxCocoa
import Combine
import Moya

enum HomeAction {
    case play(RadioStation)
    case ready
    case tryFetchNextPage
    case toggleFavorites(RadioStation)
}

enum HomeMutation {
    case fetching(Bool)
    case stations([RadioStation], reset: Bool)
    case page(Int)
    case hasNextPage(Bool)
    case updateStation(RadioStation)
}

enum HomeEvent {
    case coordinate(HomeCoordinator.Location)
}

extension HomeEvent: Coordinating {
    var location: HomeCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct HomeState {
    @Drived var fetching: Bool = false
    @Drived var stations: [RadioStation] = []
    
    var page = 0
    var hasNextPage = true
}

final class HomeViewModel: CoordinatingViewModel<HomeAction, HomeMutation, HomeEvent, HomeState> {
    let service: RadioService
    let favoritesService: FavoritesService
    let player: Player
        
    init<C: Coordinator>(service: RadioService, favoritesService: FavoritesService, coordinator: C, player: Player) where C.Location == Event.Location {
        self.service = service
        self.favoritesService = favoritesService
        self.player = player
        
        super.init(coordinator: coordinator,
                   state: HomeState()
        )
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .play(let station):
            player.play(station: station)
            return clickStation(station)
        case .ready:
            return fetchPage(0)
        case .tryFetchNextPage:
            return fetchPage(state.page + 1)
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
        case .updateStation(let station):
            for i in 0..<state.stations.count {
                if state.stations[i].stationuuid == station.stationuuid {
                    state.stations[i] = station
                    break
                }
            }
        }
    }
    
    override func transform(mutation: Observable<HomeMutation>) -> Observable<HomeMutation> {
        let changes = favoritesService.changes
            .asObservable()
            .flatMap({ changes -> Observable<HomeMutation> in
                switch changes {
                case .added(let station), .removed(let station):
                    return .just(.updateStation(station))
                }
            })
        
        return .merge(mutation, changes)
    }
}

extension HomeViewModel {
    enum Constant {
        static let PageLimit = 30
    }
    
    func clickStation(_ station: RadioStation) -> Observable<Reaction> {
        service.request(RadioBrowserTarget.clickStation(station.stationuuid)) { _ in }
        return .empty()
    }
    
    func fetchPage(_ page: Int) -> Observable<Reaction> {
        guard !state.fetching, state.hasNextPage else {
            return .empty()
        }
        let limit = Constant.PageLimit
        let offset = page * limit
        
        return Observable<Reaction>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            self.service.request(RadioBrowserTarget.mostVotedStations(offset: offset, limit: limit), success: { [weak self] (stationDTOs: [RadioBrowserStation]) in
                guard let self else {
                    observer.onCompleted()
                    return
                }
                
                let hasNextPage = stationDTOs.count >= Constant.PageLimit
                var stations = stationDTOs.map(RadioStation.init(_:))
                let uuids = stations.map(\.stationuuid)
                let favorites = self.favoritesService.filterContained(uuids)
                
                for i in 0..<stations.count {
                    stations[i].favorited = favorites.contains(stations[i].stationuuid)
                }
                
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
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .observe(on: MainScheduler.instance)
        .startWith(.mutation(.fetching(true)))
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
