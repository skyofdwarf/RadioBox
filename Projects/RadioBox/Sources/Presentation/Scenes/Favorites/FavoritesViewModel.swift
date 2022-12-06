//
//  FavoritesViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/12/01.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum FavoritesAction {
    case fetch
    case fetchNext
    case remove(RadioStation)
}

enum FavoritesMutation {
    case fetching(Bool)
    case stations([RadioStation])
    case add(RadioStation)
    case remove(RadioStation)
    
    case hasNextPage(Bool)
}

enum FavoritesEvent {
    case coordinate(FavoritesCoordinator.Location)
}

extension FavoritesEvent: Coordinating {
    var location: FavoritesCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct FavoritesState {
    @Drived var fetching: Bool = false
    @Drived var stations: [RadioStation] = []
    
    var hasNextPage = true
}

final class FavoritesViewModel: CoordinatingViewModel<FavoritesAction, FavoritesMutation, FavoritesEvent, FavoritesState> {
    let favoritesService: FavoritesService
    let service: RadioService
    let player: Player
    
    private(set) var dbag = DisposeBag()
    
    init<C: Coordinator>(service: RadioService, favoritesService: FavoritesService, coordinator: C, player: Player) where C.Location == Event.Location {
        self.service = service
        self.player = player
        self.favoritesService = favoritesService
        
        super.init(coordinator: coordinator, state: State())
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .fetch:
            return fetchFavorites()
        case .fetchNext:
            return fetchFavorites()
        case .remove(let station):
            return remove(station)
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .stations(let stations):
            state.stations += stations
        case .hasNextPage(let hasNextPage):
            state.hasNextPage = hasNextPage
        case .add(let station):
            if !state.stations.contains(station) {
                state.stations.append(station)
            }
        case .remove(let station):
            if let index = state.stations.firstIndex(where: { $0.stationuuid == station.stationuuid }) {
                state.stations.remove(at: index)
            }
        }
    }
    
    override func transform(mutation: Observable<FavoritesMutation>) -> Observable<FavoritesMutation> {
        let changes = favoritesService.changes
            .asObservable()
            .flatMap({ changes -> Observable<FavoritesMutation> in
                switch changes {
                case .added(let station):
                    return .just(.add(station))
                case .removed(let station):
                    return .just(.remove(station))
                }
            })
        
        return .merge(mutation, changes)
    }
}

extension FavoritesViewModel {
    enum Constant {
        static let PageLimit = 30
    }
    
    func fetchFavorites() -> Observable<Reaction> {
        guard favoritesService.available,
              !state.fetching,
              state.hasNextPage
        else {
            return .empty()
        }
        let limit = Constant.PageLimit
        let offset = state.stations.count
        
        return Observable<Reaction>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let stations = self.favoritesService.fetch(paging: (offset: offset, limit: limit))
            let hasNextPage = stations.count >= Constant.PageLimit
            
            observer.onNext(.mutation(.hasNextPage(hasNextPage)))
            observer.onNext(.mutation(.stations(stations)))
            observer.onCompleted()
            
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
        .observe(on: MainScheduler.instance)
        .startWith(.mutation(.fetching(true)))
        .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
    }
    
    func remove(_ station: RadioStation) -> Observable<Reaction> {
        guard favoritesService.available
        else {
            return .empty()
        }
        
        return Observable<Reaction>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let success = self.favoritesService.remove(station)
            if success {
                observer.onNext(.mutation(.remove(station)))
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
