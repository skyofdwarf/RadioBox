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
    let artistLabel: UILabel
    let titleLabel: UILabel
    
    var player: Player?
    
    private var dbag: [AnyCancellable] = []
    
    override init(frame: CGRect) {
        playButton = UIButton(type: .system).then {
            $0.setImage(PlayerStatus.disabled.image, for: .normal)
        }
        faviconImageView = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.tintColor = .secondaryLabel
            $0.backgroundColor = .systemGroupedBackground
        }
        titleLabel = UILabel().then {
            $0.font = UIFont.preferredFont(for: .callout, weight: .semibold)
            $0.textColor = .label
            $0.lineBreakMode = .byTruncatingTail
        }
        artistLabel = UILabel().then {
            $0.font = UIFont.preferredFont(forTextStyle: .callout)
            $0.textColor = .label
            $0.lineBreakMode = .byTruncatingTail
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
        
        let infoStackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel]).then {
            $0.axis = .vertical
            $0.spacing = 4
        }
        
        subviews {
            container.subviews {
                faviconImageView
                infoStackView
                playButton
            }
        }
        
        container.layout {
            0
            |faviconImageView-infoStackView-playButton|
            0
        }
        
        container.fillContainer()
        infoStackView.centerVertically()
        playButton.size(Self.barHeight)
        faviconImageView.size(Self.barHeight)
    }
    
    func updatePlayButton(status: PlayerStatus) {
        playButton.isEnabled = status != .disabled
        playButton.setImage(status.image, for: .normal)
        playButton.tintColor = status == .waitingToPlay ? .systemGray : .systemBlue
    }
    
    func updateInfo(with station: RadioStation?) {
        if let station {
            titleLabel.text = station.name
            updateFavicon(with: URL(string: station.favicon))
        } else {
            titleLabel.text = "Select a station to listen!"
            updateFavicon(with: nil)
        }
        
        titleLabel.isHidden = false
        artistLabel.isHidden = true
    }
    
    func updateTitle(with title: String) {
        let tokens = title.split(separator: "-")
        if tokens.count > 1 {
            titleLabel.text = String(tokens[1]).trimmingCharacters(in: CharacterSet.whitespaces)
            artistLabel.text = String(tokens[0]).trimmingCharacters(in: CharacterSet.whitespaces)
            
            artistLabel.numberOfLines = 1
        } else {
            titleLabel.text = title
            artistLabel.text = nil
            
            titleLabel.numberOfLines = 2
        }
        
        titleLabel.isHidden = false
        artistLabel.isHidden = tokens.count == 1
    }
    
    func updateFavicon(with url: URL?) {
        faviconImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "radio"))
    }
        
    func bind(player: Player) {
        dbag = []
        self.player = player
        
        player.status.sink { [weak self] status in
            self?.updatePlayButton(status: status)
        }.store(in: &dbag)
        
        player.station.sink { [weak self] station in
            self?.updateInfo(with: station)
        }.store(in: &dbag)
        
        player.streamTitle.sink { [weak self] title in
            self?.updateTitle(with: title)
        }.store(in: &dbag)
        
        player.streamUrl.sink { [weak self] urlString in
            self?.updateFavicon(with: URL(string: urlString))
        }.store(in: &dbag)
        
        
        player.error.sink {
            print("error: \($0)")
        }.store(in: &dbag)
    }
}

// https://mackarous.com/dev/2018/12/4/dynamic-type-at-any-font-weight
extension UIFont {
    static func preferredFont(for style: TextStyle, weight: Weight) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}
