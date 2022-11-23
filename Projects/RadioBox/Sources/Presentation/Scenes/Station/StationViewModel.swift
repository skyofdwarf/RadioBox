//
//  StationViewModel.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/23.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift
import RxCocoa
import Combine
import Moya

enum StationAction {
    case favorite(Bool)
    case vote
}

enum StationMutation {
    case favorited(Bool)
    case fetching(Bool)
}

enum StationEvent {
    case coordinate(StationCoordinator.Location)
}

extension StationEvent: Coordinating {
    var location: StationCoordinator.Location? {
        switch self {
        }
    }
}

struct StationState {
    var station: RadioStation
    @Drived var favorited: Bool = false
    @Drived var fetching: Bool = false
}

final class StationViewModel: CoordinatingViewModel<StationAction, StationMutation, StationEvent, StationState> {
    let service: RadioService
    let player: Player
        
    init<C: Coordinator>(station: RadioStation, service: RadioService, coordinator: C, player: Player) where C.Location == Event.Location {
        self.service = service
        self.player = player
        
        super.init(coordinator: coordinator,
                   state: State(station: station, favorited: false)
        )
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .favorite(let favorite):
            // TODO: toggle favorited
            return .empty()
            
        case .vote:
            // TODO: vote station
            return .empty()
        }
    }
        
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .favorited(let favorited):
            state.favorited = favorited
        case .fetching(let fetching):
            state.fetching = fetching
        }
    }
}

extension StationViewModel {
    enum Constant {
        static let PageLimit = 30
    }
    
    func vote(station: RadioStation) -> Observable<Reaction> {
        guard !state.fetching else {
            return .empty()
        }

        return .empty()
//        return Observable<Reaction>.create { [weak self] observer in
//            self?.service.request(RadioBrowserTarget.mostVotedStations(offset: offset, limit: limit), success: { (stationDTOs: [RadioBrowserStation]) in
//                let hasNextPage = stationDTOs.count >= Constant.PageLimit
//                let stations = stationDTOs.map(RadioStation.init(_:))
//                observer.onNext(.mutation(.page(page)))
//                observer.onNext(.mutation(.hasNextPage(hasNextPage)))
//                observer.onNext(.mutation(.stations(stations, reset: offset == 0)))
//                observer.onCompleted()
//            }, failure: {
//                observer.onNext(.error($0))
//                observer.onCompleted()
//            })
//            return Disposables.create()
//        }
//        .startWith(.mutation(.fetching(true)))
//        .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
    }
}

