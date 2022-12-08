//
//  CustomNavigationController.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/24.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
