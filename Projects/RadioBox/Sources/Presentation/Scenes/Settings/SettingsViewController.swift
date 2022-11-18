//
//  SettingsViewController.swift
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

class SettingsViewController: UIViewController {
    let label = UILabel()
    let radioImageView = UIImageView(image: UIImage(systemName: "antenna.radiowaves.left.and.right"))
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    
    var vm: SettingsViewModel!
    var dbag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tabBarItem = UITabBarItem(title: "Settings",
                                  image: UIImage(systemName: "gear"),
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
        label.text = "Settings"
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
        }
        
        view.layout {
            |-label-|
            radioImageView.size(200)
            |-indicatorView-|
        }
        
        radioImageView.centerInContainer()
    }
    
    func bindViewModel() {
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
    }
}
