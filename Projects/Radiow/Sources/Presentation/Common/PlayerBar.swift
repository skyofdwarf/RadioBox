//
//  PlayerBar.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/18.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import Kingfisher
import Combine
import MediaPlayer

extension PlayerStatus {
    var image: UIImage? { UIImage(systemName: symbolName) }
    
    var symbolName: String {
        switch self {
        case .playing: return "stop.fill"
        case .stopped: return "play.fill"
        case .waitingToPlay: return "waveform.path"
        case .disabled: return "play.fill"
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
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 5
            $0.tintColor = .secondaryLabel
        }
        titleLabel = UILabel().then {
            $0.font = UIFont.preferredFont(for: .callout, weight: .semibold)
            $0.textColor = .label
            $0.lineBreakMode = .byTruncatingTail
        }
        artistLabel = UILabel().then {
            $0.font = UIFont.preferredFont(forTextStyle: .callout)
            $0.textColor = .secondaryLabel
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
    
    @objc func playButtonDidTap(_ sender: Any) {
        player?.toggle()
    }
    
    func setup() {
        playButton.addTarget(self, action: #selector(playButtonDidTap(_:)), for: .touchUpInside)
        
        let container = UIView().then {
            $0.clipsToBounds = true
        }
        let faviconContainer = UIView()
        
        let infoStackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel]).then {
            $0.axis = .vertical
            $0.spacing = 4
        }
        
        subviews {
            container.subviews {
                faviconContainer.subviews {
                    faviconImageView
                }
                infoStackView
                playButton
            }
        }
        
        container.layout {
            5
            |-10-faviconContainer-infoStackView-playButton|
            5
        }

        faviconContainer.heightEqualsWidth()
        faviconImageView.centerInContainer()
        faviconImageView.Width == faviconContainer.Width
        faviconImageView.heightEqualsWidth()
        
        faviconImageView.CenterX == faviconContainer.CenterX
        faviconImageView.CenterY == faviconContainer.CenterY

        container.fillContainer()
        playButton.size(Self.barHeight)
    }
    
    func updatePlayButton(status: PlayerStatus) {
        playButton.isEnabled = status != .disabled
        playButton.setImage(status.image, for: .normal)
        playButton.tintColor = status == .waitingToPlay ? .systemGray : .systemBlue
    }
    
    func updateInfo(with station: RadioStation?) {
        if let station {
            titleLabel.text = station.name
            updateFavicon(url: URL(string: station.favicon))
        } else {
            titleLabel.text = "Select a station to listen!"
            updateFavicon(url: nil)
        }
        
        titleLabel.isHidden = false
        artistLabel.isHidden = true
    }
    
    func updateTitle(_ title: String, artist: String?) {
        titleLabel.text = title
        artistLabel.text = artist
        
        titleLabel.numberOfLines = artist == nil ? 2: 1
        artistLabel.isHidden = artist == nil
    }
    
    func updateFavicon(url: URL?) {
        func fixFaviconVerticalOffset() {
            guard let image = faviconImageView.image else { return }
            
            faviconImageView.centerYConstraint?.constant = image.alignmentRectInsets.top
        }
        
        faviconImageView.kf.setImage(with: url,
                                     placeholder: UIImage(systemName: "music.note.list"),
                                     options: [ .transition(.fade(0.3)) ]) {
            switch $0 {
            case .success:
                fixFaviconVerticalOffset()
            default: break
            }
        }
    }
                
    func bind(player: Player) {
        dbag = []
        self.player = player
        
        player.statusPublisher.sink { [weak self] status in
            self?.updatePlayButton(status: status)
        }.store(in: &dbag)
        
        player.stationPublisher.sink { [weak self] station in
            self?.updateInfo(with: station)
        }.store(in: &dbag)
        
        player.streamTitlePublisher.sink { [weak self] (title, artist) in
            self?.updateTitle(title, artist: artist)
        }.store(in: &dbag)
        
        player.streamArtworkPublisher.sink { [weak self] url in
            self?.updateFavicon(url: url)
        }.store(in: &dbag)
        
        
        player.errorPublisher.sink {
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
