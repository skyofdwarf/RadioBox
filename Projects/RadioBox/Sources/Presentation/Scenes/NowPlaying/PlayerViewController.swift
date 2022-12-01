//
//  PlayerViewController.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/28.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import Combine
import MediaPlayer
import AVKit

class PlayerViewController: UIViewController {
    let imageContainerView = UIView()
    let controlContainerView = UIView()
    let stationInfoStackView = UIStackView()
    
    let imageView = UIImageView()
    let stationNameLabel = UILabel()
    let stationSpecLabel = UILabel()
    let stationTagsLabel = UILabel()
    
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    
    let playButton = UIButton(type: .system)
    
    let volumeView = MPVolumeView()
    let minVolumeImageView = UIImageView()
    let maxVolumeImageView = UIImageView()
    let routePickerView = AVRoutePickerView()
    
    var vm: PlayerViewModel!

    private(set) var dbag = DisposeBag()
    private(set) var cbag: [AnyCancellable] = []

    deinit {
        print("\(#file).\(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        configureSubviews()
        bindViewModel()
    }
    
    func configureSubviews() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.tintColor = .systemGray
        imageView.layer.cornerRadius = 10
        
        stationInfoStackView.axis = .vertical
        stationNameLabel.font = .preferredFont(forTextStyle: .caption2)
        stationSpecLabel.font = .preferredFont(forTextStyle: .caption2)
        stationTagsLabel.font = .preferredFont(forTextStyle: .caption2)
        stationNameLabel.textColor = .secondaryLabel
        stationSpecLabel.textColor = .tertiaryLabel
        stationTagsLabel.textColor = .tertiaryLabel
        stationNameLabel.textAlignment = .center
        stationSpecLabel.textAlignment = .center
        stationTagsLabel.textAlignment = .center
        stationTagsLabel.numberOfLines = 0
        
        titleLabel.font = .preferredFont(forTextStyle: .title1)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        artistLabel.font = .preferredFont(forTextStyle: .body)
        artistLabel.textColor = .secondaryLabel
        artistLabel.numberOfLines = 1
        
        let playImage = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        playButton.setImage(playImage, for: .normal)
        playButton.tintColor = .label
        
        let action = UIAction { [weak self] _ in
            self?.vm.player.toggle()
        }
        playButton.addAction(action, for: .touchUpInside)
        
        minVolumeImageView.image = UIImage(systemName: "speaker.fill")
        maxVolumeImageView.image = UIImage(systemName: "speaker.wave.3.fill")
        minVolumeImageView.tintColor = .systemGray2
        maxVolumeImageView.tintColor = .systemGray2
        
        volumeView.showsVolumeSlider = true
        volumeView.showsRouteButton = false
        
        volumeView.tintColor = .lightGray
        
        routePickerView.tintColor = .label

        // hide thumb
        let size = CGSize(width: 48, height: 48)
        let image = UIGraphicsImageRenderer(size: size).image { _ in }
        
        volumeView.setVolumeThumbImage(image, for: .normal)

        layoutSubviews()
    }

    func layoutSubviews() {
        let volumeContainer = UIView()
        view.subviews {
            imageContainerView
            controlContainerView
        }
        
        let infoStackView = UIStackView(arrangedSubviews: [imageView, stationInfoStackView]).then {
            $0.axis = .vertical
            $0.spacing = 10
        }
        imageContainerView.subviews {
            infoStackView
        }

        controlContainerView.subviews {
            titleLabel
            artistLabel
            playButton
            volumeContainer.subviews {
                minVolumeImageView
                maxVolumeImageView
                volumeView
            }
            routePickerView
        }
        
        stationInfoStackView.addArrangedSubview(stationNameLabel)
        stationInfoStackView.addArrangedSubview(stationSpecLabel)
        stationInfoStackView.addArrangedSubview(stationTagsLabel)
        
        imageContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        infoStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.bottom.greaterThanOrEqualToSuperview()
            $0.leading.equalToSuperview().inset(60)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.width.equalTo(imageView.snp.height)
        }
        
        controlContainerView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(imageContainerView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(40)
        }
        
        artistLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(40)
        }
        
        playButton.snp.makeConstraints {
            $0.top.equalTo(artistLabel.snp.bottom).offset(30)
            $0.size.equalTo(CGSize(width: 48, height: 48))
            $0.centerX.equalToSuperview()
        }
        
        volumeContainer.snp.makeConstraints {
            $0.top.equalTo(playButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(40)
            
            $0.height.equalTo(56)
        }
        minVolumeImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-8)
        }
        maxVolumeImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-8)
        }
        volumeView.snp.makeConstraints {
            $0.leading.equalTo(minVolumeImageView.snp.trailing).offset(10)
            $0.trailing.equalTo(maxVolumeImageView.snp.leading).offset(-10)
            
            $0.height.equalTo(32)
            $0.centerY.equalToSuperview()
        }
        
        routePickerView.snp.makeConstraints {
            $0.top.equalTo(volumeContainer.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().inset(40)
            $0.trailing.equalToSuperview().inset(40)
        }
    }

    func bindViewModel() {
        vm.player.status.sink { [weak self] status in
            let image = UIImage(systemName: status.symbolName, withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            self?.playButton.setImage(image, for: .normal)
            
            self?.playButton.tintColor = status == .waitingToPlay ? .systemGray : .systemBlue
            self?.playButton.isEnabled = status != .disabled
        }.store(in: &cbag)
        
        vm.player.station
            .sink { [weak self] in
                guard let station = $0 else { return }
                let info = [station.codec, String(station.bitrate), station.country]
                    .filter { !$0.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty }
                    .joined(separator: " / ")
                
                self?.stationNameLabel.text = station.name
                self?.stationSpecLabel.text = info
                self?.stationTagsLabel.text = station.tags
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
                    .map { $0.hasPrefix("#") ? $0 : "#\($0)" }
                    .joined(separator: " ")
            }.store(in: &cbag)
        
        vm.player.streamTitle
            .map { $0.title }
            .sink { [weak self] in
                self?.titleLabel.text = $0
            }.store(in: &cbag)
        
        vm.player.streamTitle
            .map { $0.artist }
            .sink { [weak self] in
                self?.artistLabel.text = $0
            }.store(in: &cbag)
        
        vm.player.streamArtwork
            .sink { [weak self] url in
                self?.imageView.kf.setImage(with: url,
                                           placeholder: UIImage(systemName: "music.note.house"),
                                           options: [ .transition(.fade(0.3)) ])
            }.store(in: &cbag)
        
        vm.player.error
            .sink {
                print("error: \($0)")
            }.store(in: &cbag)
    }
}
