//
//  PlayerBar.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/18.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import Kingfisher
import Combine

extension PlayerStatus {
    var image: UIImage? {
        switch self {
        case .playing: return UIImage(systemName: "stop")
        case .stopped: return UIImage(systemName: "play")
        }
    }
}

class PlayerBar: UIToolbar {
    static let barHeight: CGFloat = 60
    
    let playButton: UIButton
    let faviconImageView: UIImageView
    let infoLabel: UILabel
    
    private(set) var player: RadioPlayer?
    
    private var dbag: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        playButton = UIButton(type: .system).then {
            $0.size(Self.barHeight)
        }
        faviconImageView = UIImageView().then {
            $0.size(Self.barHeight)
            $0.backgroundColor = .systemYellow
        }
        infoLabel = UILabel().then {
            $0.font = UIFont.preferredFont(forTextStyle: .caption2)
            $0.textColor = .label
            $0.numberOfLines = 0
            $0.text = " HI HI? HIHI HI? HIHI HI? HIHI HI? HIHI HI? HIHI HI? HIHI HI? HIHI HI? HI"
        }
        
        super.init(frame: frame)
        
        setup()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: .zero, height: Self.barHeight)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = Self.barHeight
        return size
    }
    
    func setup() {
        playButton.setImage(PlayerStatus.stopped.image, for: .normal)
        playButton.addAction(UIAction { [weak player] _ in player?.togglePlay() }, for: .touchUpInside)
        
        subviews {
            faviconImageView
            infoLabel
            playButton
        }
        
        layout {
            0
            |faviconImageView-(infoLabel.top(0).bottom(0))-playButton|
            0
        }
    }
    
    func updatePlayButton(status: PlayerStatus) {
        if let statusImage = status.image {
            playButton.setImage(statusImage, for: .normal)
            playButton.isEnabled = true
        } else {
            playButton.isEnabled = false
        }
    }
        
    func bind(player: RadioPlayer) {
        dbag = []
        self.player = player
        
        player.status.sink { [weak self] status in
            self?.updatePlayButton(status: status)
        }.store(in: &dbag)
        
        player.station.sink { [weak self] station in
            if let station {
                self?.infoLabel.text = station.name
                self?.faviconImageView.kf.setImage(with: URL(string: station.favicon))
            } else {
                self?.infoLabel.text = nil
                self?.faviconImageView.image = UIImage(systemName: "radio")
            }
        }.store(in: &dbag)
    }
}
