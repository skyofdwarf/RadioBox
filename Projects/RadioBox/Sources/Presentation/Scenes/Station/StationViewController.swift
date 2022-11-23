//
//  StationViewController.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/22.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import RxSwift

class StationViewController: UIViewController {
    let scrollView = UIScrollView()
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    let imageView = UIImageView()
    let nameLabel = UILabel()
    let tagsLabel = UILabel()
    let infoLabel = UILabel()
    
    var vm: StationViewModel!
    
    private(set) var dbag = DisposeBag()
    
    deinit {
        print("\(#file).\(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        configureSubviews()
        bindViewModel()
//        bindPlayer()
    }
    
    func configureSubviews() {
        scrollView.backgroundColor = .systemBackground
        
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        nameLabel.font = .preferredFont(forTextStyle: .title1)
        nameLabel.numberOfLines = 0
        nameLabel.textColor = .label
        nameLabel.textAlignment = .center
        
        tagsLabel.font = .preferredFont(forTextStyle: .caption1)
        tagsLabel.numberOfLines = 0
        tagsLabel.textColor = .label
        tagsLabel.textAlignment = .center
        
        infoLabel.font = .preferredFont(forTextStyle: .caption1)
        infoLabel.numberOfLines = 1
        infoLabel.textColor = .label
        infoLabel.textAlignment = .center
        
        layoutSubviews()
    }
    
    func layoutSubviews() {
        let contentView = UIView()
        contentView.backgroundColor = .systemBackground
        
        view.subviews {
            scrollView.subviews {
                contentView.subviews {
                    imageView
                    infoLabel
                    nameLabel
                    tagsLabel
                }
            }
            indicatorView
        }
        
        scrollView.fillContainer()
        scrollView.layout {
            0
            |contentView|
            0
        }
        
        contentView.Width == scrollView.Width
        contentView.layout {
            0
            imageView
            16
            |-24-nameLabel-24-|
            4
            |-24-infoLabel-24-|
            16
            |-24-tagsLabel-24-|
            >=12
        }
        
        imageView.size(240)
        imageView.CenterX == contentView.CenterX
        
        indicatorView.centerInContainer()
        
//        playerBar.fillHorizontally()
//        playerBar.Top == view.safeAreaLayoutGuide.Bottom
//
//        additionalSafeAreaInsets = UIEdgeInsets(top: 0,
//                                                left: 0,
//                                                bottom: playerBar.intrinsicContentSize.height,
//                                                right: 0)
    }
    
    func bindViewModel() {
        imageView.kf.setImage(with: URL(string: vm.state.station.favicon),
                              placeholder: UIImage(systemName: "radio"),
                              options: [ .transition(.fade(0.3)) ])
        
        let station = vm.state.station
        
        let info = [station.codec, String(station.bitrate), station.country]
            .filter { !$0.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty }
            .joined(separator: " / ")
        
        infoLabel.text = info
        nameLabel.text = station.name
        tagsLabel.text = station.tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
            .map { $0.hasPrefix("#") ? $0 : "#\($0)" }
            .joined(separator: " ")
        
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
        
//        vm.state.$favorited
//            .withUnretained(self)
//            .drive((onNext: { vc, stations in
//                vc.applyDataSource(stations: stations)
//            })
//            .disposed(by: dbag)
    }
    
//    func bindPlayer() {
//        playerBar.bind(player: vm.player)
//    }
}
