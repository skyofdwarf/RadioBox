//
//  SearchViewController.swift
//  RadioBox
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import RxRelay
import RxCocoa

class SearchViewController: UIViewController {
    let label = UILabel()
    let radioImageView = UIImageView(image: UIImage(systemName: "antenna.radiowaves.left.and.right"))
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    let playerBar = PlayerBar()
    
    var vm: SearchViewModel!
    var dbag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: "Search",
                                  image: UIImage(systemName: "magnifyingglass.circle"),
                                  tag: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureSubviews()
        layoutSubviews()
        bindViewModel()
        
//        vm.send(action: .lookup)
    }
    
    func configureSubviews() {
        label.text = "Search"
        label.textAlignment = .center
        radioImageView.contentMode = .scaleAspectFit
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
    }
    
    func layoutSubviews() {
        view.subviews {
            label
            radioImageView
            indicatorView
            playerBar
        }
        
        view.layout {
            |-label-|
            radioImageView.size(200)
            |-indicatorView-|
        }
        
        radioImageView.centerInContainer()
        
        playerBar.fillHorizontally()
        playerBar.Top == view.safeAreaLayoutGuide.Bottom
        
        additionalSafeAreaInsets = UIEdgeInsets(top: 0,
                                                left: 0,
                                                bottom: playerBar.intrinsicContentSize.height,
                                                right: 0)
    }
    
    func bindViewModel() {
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
    }
}
