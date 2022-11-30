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
    let imageView = UIImageView()
    let infoLabel = UILabel()
    let nameLabel = UILabel()
    
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
        infoLabel.numberOfLines = 1
        infoLabel.textAlignment = .center
        infoLabel.textColor = UIColor.label
        infoLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        infoLabel.adjustsFontForContentSizeCategory = true
        
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.label
        nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        nameLabel.adjustsFontForContentSizeCategory = true
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .secondaryLabel
        
        let imageViewContainer = UIView()
        imageViewContainer.backgroundColor = .systemGroupedBackground
        imageViewContainer.clipsToBounds = true
        imageViewContainer.layer.cornerRadius = 10
        
        subviews {
            imageViewContainer.subviews {
                imageView
            }
            infoLabel
            nameLabel
        }
        
        layout {
            0
            |imageViewContainer|
            |infoLabel|
            4
            |-4-nameLabel-4-|
            >=0
        }
        
        imageViewContainer.heightEqualsWidth()
        imageView.fillContainer()
        
        infoLabel.height(12)
        nameLabel.height(>=14)
    }
    
    func configure(station: RadioStation) {
        let url = URL(string: station.favicon)
        
        task?.cancel()
        task = imageView.kf.setImage(with: url,
                                     placeholder: UIImage(systemName: "radio"),
                                     options: [ .transition(.fade(0.3)) ])
        
        
        infoLabel.text = "\(station.codec) / \(station.bitrate)"
        nameLabel.text = station.name
    }
}
