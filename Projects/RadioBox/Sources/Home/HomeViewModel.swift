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
import RxCocoa
import Combine
import Moya

enum HomeAction {
    case ready
}

enum HomeMutation {
    case fetching(Bool)
    case stations([RadioStation])
}

enum HomeEvent {
    case coordinate(HomeCoordinator.Location)
}

struct HomeState {
    @Drived var fetching: Bool = false
    @Drived var stations: [RadioStation] = []
}

final class HomeViewModel: ViewModel<HomeAction, HomeMutation, HomeEvent, HomeState> {
    let service: RadioService
    weak var coordinator: HomeCoordinator?
        
    init(service: RadioService, coordinator: HomeCoordinator) {
        self.service = service
        self.coordinator = coordinator
        
        super.init(state: HomeState(),
                   eventMiddlewares: [Self.coordinating(coordinator)]
        )
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        case .ready:
            return Observable<Reaction>.create { [weak self] observer in
                self?.service.request(RadioBrowserTarget.mostVotedStations(offset: 0, limit: 10), success: { (stationDTOs: [RadioBrowserStation]) in
                    let stations = stationDTOs.map(RadioStation.init(_:))
                    observer.onNext(Reaction.mutation(.stations(stations)))
                    observer.onCompleted()
                }, failure: {
                    observer.onNext(Reaction.error($0))
                    observer.onCompleted()
                })
                return Disposables.create()
            }
            .startWith(.mutation(.fetching(true)))
            .concat(Observable<Reaction>.just(.mutation(.fetching(false))))
        }
    }
        
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        case .stations(let stations):
            state.stations = stations
        }
    }
}

extension HomeViewModel {
    static func coordinating(_ coordinator: HomeCoordinator) -> EventMiddleware {
        middleware.event { store, next, event in
            if case let .coordinate(location) = event {
                coordinator.coordinate(location)
            }
            return next(event)
        }
    }
}
