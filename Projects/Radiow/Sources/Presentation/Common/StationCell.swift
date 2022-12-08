//
//  StationCell.swift
//  Radiow
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
    
    let favoriteButton = UIButton(type: .custom)
    
    var toggleFavorites: ((Bool) -> Void)?
    
    private var task: DownloadTask?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        toggleFavorites = nil
        
        task?.cancel()
        task = nil
    }
    
    func setup() {
        infoLabel.numberOfLines = 1
        infoLabel.textAlignment = .center
        infoLabel.textColor = .secondaryLabel
        infoLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
        infoLabel.adjustsFontForContentSizeCategory = true
        
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.label
        nameLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        nameLabel.adjustsFontForContentSizeCategory = true
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel

        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .headline, scale: .large)
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonDidTap(_:)), for: .touchUpInside)
        favoriteButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .normal)
        favoriteButton.setPreferredSymbolConfiguration(symbolConfiguration, forImageIn: .selected)
        favoriteButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "bookmark.fill"), for: .selected)
        favoriteButton.tintColor = .systemRed
        favoriteButton.backgroundColor = .systemRed.withAlphaComponent(0.2)
        favoriteButton.layer.cornerRadius = 38/2
        favoriteButton.layer.borderColor = UIColor.systemRed.cgColor
        favoriteButton.layer.borderWidth = 2
        
                
        let imageViewContainer = UIView()
        imageViewContainer.backgroundColor = .systemGroupedBackground
        imageViewContainer.clipsToBounds = true
        imageViewContainer.layer.cornerRadius = 10
        
        subviews {
            imageViewContainer.subviews {
                imageView
            }
            nameLabel
            infoLabel
            favoriteButton
        }
        
        layout {
            0
            |imageViewContainer|
            |nameLabel|
            2
            |-4-infoLabel-4-|
            >=0
        }
        
        favoriteButton.top(10).right(10).size(38)
        
        imageViewContainer.heightEqualsWidth()
        imageView.fillContainer()
        
        infoLabel.height(12)
        nameLabel.height(>=14)
    }
    
    @objc func favoriteButtonDidTap(_ sender: UIButton) {
        toggleFavorites?(!sender.isSelected)
    }
    
    func configure(station: RadioStation) {
        let url = URL(string: station.favicon)
        
        task?.cancel()
        task = imageView.kf.setImage(with: url,
                                     placeholder: UIImage(systemName: "music.note.house"),
                                     options: [ .transition(.fade(0.3)) ])
        
        
        nameLabel.text = station.name
        infoLabel.text = [station.codec, String(station.bitrate), station.country]
            .filter { !$0.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty }
            .joined(separator: " / ")
        
        favoriteButton.isSelected = station.favorited
    }
}
