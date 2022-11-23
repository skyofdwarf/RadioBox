//
//  Coordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/17.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

protocol Coordinating {
    associatedtype Location
    var location: Location? { get }
}

protocol Coordinator: AnyObject {
    associatedtype Location
    associatedtype Target
    
    /// A target currently managed by coordinator
    var target: Target? { get }
        
    /// Instantiates a new target. this instance is not managed yet by this coordinator
    /// You should call this method to create a new target instance in `start()` or outside of the coordinator.
    /// - Returns: new target instance
    func instantiateTarget() -> Target
    
    /// Coordinates to target managed by this coordinator
    /// - Returns: a target instance created
    @discardableResult
    func start() -> Target
    
    /// Coordinates to location from target
    /// - Parameter location: target to locate
    func coordinate(_ location: Location)
}

extension Coordinator {
    func coordinate(_ location: Location) {}
}
