//
//  StationSectionHeaderView.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/17.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia

class StationSectionHeaderView: UICollectionReusableView {
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setup() {
        // config
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor.label
        
        // layout
        subviews(label)
        
        label.fillContainer()
    }
    
    func configure(title: String) {
        label.text = title
    }
}
