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
        case .waitingToPlay: return UIImage(systemName: "waveform.path")
        case .disabled: return UIImage(systemName: "play")
        }
    }
}

class PlayerBar: UIToolbar {
    static let barHeight: CGFloat = 60
    
    let playButton: UIButton
    let faviconImageView: UIImageView
    let infoLabel: UILabel
    
    var player: Player?
    
    private var dbag: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        playButton = UIButton(type: .system).then {
            $0.setImage(PlayerStatus.stopped.image, for: .normal)
        }
        faviconImageView = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.tintColor = .secondaryLabel
            $0.backgroundColor = .systemGroupedBackground
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
        let action = UIAction { [weak self] _ in
            self?.player?.toggle()
        }
        playButton.addAction(action, for: .touchUpInside)
        
        let container = UIView().then {
            $0.clipsToBounds = true
        }
        
        subviews {
            container.subviews {
                faviconImageView
                infoLabel
                playButton
            }
        }
        
        container.layout {
            0
            |faviconImageView-(infoLabel.top(0).bottom(0))-playButton|
            0
        }
        
        container.fillContainer()
        playButton.size(Self.barHeight)
        faviconImageView.size(Self.barHeight)
    }
    
    func updatePlayButton(status: PlayerStatus) {
        playButton.isEnabled = status != .disabled
        playButton.setImage(status.image, for: .normal)
        playButton.tintColor = status == .waitingToPlay ? .systemGray : .systemBlue
    }
        
    func bind(player: Player) {
        dbag = []
        self.player = player
        
        player.status.sink { [weak self] status in
            self?.updatePlayButton(status: status)
        }.store(in: &dbag)
        
        player.station.sink { [weak self] station in
            if let station {
                self?.infoLabel.text = station.name
                self?.faviconImageView.kf.setImage(with: URL(string: station.favicon), placeholder: UIImage(systemName: "radio"))
            } else {
                self?.infoLabel.text = nil
                self?.faviconImageView.image = UIImage(systemName: "radio")
            }
        }.store(in: &dbag)
        
        player.error.sink {
            print("error: \($0)")
        }.store(in: &dbag)
    }
}
