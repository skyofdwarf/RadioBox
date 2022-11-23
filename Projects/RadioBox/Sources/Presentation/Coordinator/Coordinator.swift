//
//  Coordinator.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/17.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

protocol Coordinating {
    associatedtype Location
    var location: Location? { get }
}

protocol Coordinator: AnyObject {
    associatedtype Location
    associatedtype VC
    
    var vc: VC? { get }
    
    func coordinate(_ location: Location)
}

