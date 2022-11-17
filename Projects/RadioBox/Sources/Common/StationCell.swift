//
//  StationCell.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/17.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import Kingfisher

class StationCell: UICollectionViewCell {
    let label = UILabel()
    let imageView = UIImageView()
    
    var task: DownloadTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        task?.cancel()
        task = nil
    }
    
    func setup() {
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = UIColor.label
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGroupedBackground
        imageView.tintColor = .secondaryLabel
        
        let imageViewContainer = UIView()
        
        subviews(
            imageViewContainer.subviews(
                imageView
            ),
            label
        )
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        layout {
            0
            |imageViewContainer|
            0
            |-4-label-4-|
            0
        }
        
        imageViewContainer.heightEqualsWidth()
        imageView.fillContainer()
    }
    
    func configure(station: RadioStation) {
        let url = URL(string: station.favicon)
        
        task?.cancel()
        task = imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "radio"))
        
        label.text = station.name
    }
}
