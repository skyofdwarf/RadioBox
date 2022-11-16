//
//  MainViewController.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
