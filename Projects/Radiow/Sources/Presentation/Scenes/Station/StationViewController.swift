//
//  StationViewController.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/22.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import SnapKit
import RxSwift
import Combine
import Kingfisher

class StationViewController: UIViewController {
    let imageContainerView = UIView()
    let stationInfoStackView = UIStackView()
    
    let imageView = UIImageView()
    let stationNameLabel = UILabel()
    let stationSpecLabel = UILabel()
    let stationTagsLabel = UILabel()
    
    var vm: StationViewModel!
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = imageContainerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
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
        stationTagsLabel.numberOfLines = 3
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        let mainContainerStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 0
            $0.addArrangedSubview(imageContainerView)
        }
        
        view.subviews {
            mainContainerStackView
        }
        
        imageContainerView.subviews {
            imageView
            stationInfoStackView
        }
        
        stationInfoStackView.addArrangedSubview(stationNameLabel)
        stationInfoStackView.addArrangedSubview(stationSpecLabel)
        stationInfoStackView.addArrangedSubview(stationTagsLabel)
        
        mainContainerStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.greaterThanOrEqualToSuperview().inset(60)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(240)
            $0.height.equalTo(imageView.snp.width)
        }
        
        stationInfoStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(60)
            $0.top.equalTo(imageView.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-4)
        }
    }
    
    func bindViewModel() {
        vm.state.map(\.station)
            .drive(with: self) { this, station in
                let info = [station.codec, String(station.bitrate), station.country]
                    .filter { !$0.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty }
                    .joined(separator: " / ")
                
                this.stationNameLabel.text = station.name
                this.stationSpecLabel.text = info
                this.stationTagsLabel.text = station.tags
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
                    .map { $0.hasPrefix("#") ? $0 : "#\($0)" }
                    .joined(separator: " ")
                
                this.imageView.kf.setImage(with: URL(string: station.favicon),
                                           placeholder: UIImage(systemName: "music.note.list"),
                                           options: [ .transition(.fade(0.3)) ])
            }.disposed(by: dbag)
    }
}
