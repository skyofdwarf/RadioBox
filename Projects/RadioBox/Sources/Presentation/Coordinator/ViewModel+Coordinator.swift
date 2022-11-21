//
//  ViewModel+Coordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/17.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation
import RDXVM

extension ViewModel where Event: Coordinating {
    static func coordinating<C: Coordinator>(_ coordinator: C) -> EventMiddleware where C.Location == Event.Location {
        middleware.event { store, next, event in
            if let location = event.location {
                coordinator.coordinate(location)
            }
            
            return next(event)
        }
    }
}

class CoordinatingViewModel<Action, Mutation, Event, State>: ViewModel<Action, Mutation, Event, State> where Event: Coordinating {
    let coordinator: any Coordinator
    
    deinit {
        print("\(#file).\(#function)")
    }
    
    init<C: Coordinator>(coordinator: C,
                         state initialState: State,
                         actionMiddlewares: [ActionMiddleware] = [],
                         mutationMiddlewares: [MutationMiddleware] = [],
                         eventMiddlewares: [EventMiddleware] = [],
                         errorMiddlewares: [ErrorMiddleware] = [],
                         statePostwares: [StatePostware] = [])
    where C.Location == Event.Location {
        self.coordinator = coordinator
        
#if DEBUG
        var errorMiddlewares = errorMiddlewares
        
        let errorLogger = Self.middleware.error { store, next, error in
            print("ERROR: \(error)")
            return next(error)
        }
        
        errorMiddlewares += [ errorLogger ]
#endif
        
        super.init(state: initialState,
                   actionMiddlewares: actionMiddlewares,
                   mutationMiddlewares: mutationMiddlewares,
                   eventMiddlewares: [Self.coordinating(coordinator)] + eventMiddlewares,
                   errorMiddlewares: errorMiddlewares,
                   statePostwares: statePostwares)
    }
}
