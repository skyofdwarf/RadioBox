//
//  PlayerViewModel.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/28.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift
import RxCocoa
import Combine
import Moya

enum PlayerAction {
    case toggleFavorites
}

enum PlayerMutation {
    case fetching(Bool)
    case updateStation(RadioStation)
}

enum PlayerEvent {
    case coordinate(PlayerCoordinator.Location)
}

extension PlayerEvent: Coordinating {
    var location: PlayerCoordinator.Location? {
        switch self {
        }
    }
}

struct PlayerState {
    @Drived var fetching = false
    @Drived var station: RadioStation?
}

final class PlayerViewModel: CoordinatingViewModel<PlayerAction, PlayerMutation, PlayerEvent, PlayerState> {
    let favoritesService: FavoritesService
    let player: Player
        
    init<C: Coordinator>(coordinator: C, favoritesService: FavoritesService, player: Player) where C.Location == Event.Location {
        self.favoritesService = favoritesService
        self.player = player
        
        var state = State(station: player.station)
        
        // get favorites state in DB
        if var station = player.station {
            state.station?.favorited = favoritesService.contains(stationuuid: station.stationuuid)
        }
        
        super.init(coordinator: coordinator, state: state)
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .toggleFavorites:
            guard let station = state.station else { return .empty() }
            return toggleFavorites(station)
        }
    }
        
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .updateStation(let station):
            state.station = station
        }
    }
}

extension PlayerViewModel {
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
