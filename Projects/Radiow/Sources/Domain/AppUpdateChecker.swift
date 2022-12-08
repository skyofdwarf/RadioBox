//
//  AppUpdateChecker.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/12/08.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import Foundation

protocol AppUpdateChecker {
    func check(_ complection: @escaping (AppVersion?) -> Void)
}
