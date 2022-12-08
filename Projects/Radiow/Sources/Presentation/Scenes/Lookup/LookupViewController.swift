//
//  LookupViewController.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import Stevia
import RxSwift
import RxRelay
import RxCocoa

class LookupViewController: UIViewController {
    let radioImageView = UIImageView(image: UIImage(systemName: "radio"))
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    let retryButton = UIButton(type: .system)
    
    var vm: LookupViewModel!
    
    var dbag = DisposeBag()
    
    deinit {
        print("\(#file).\(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configureSubviews()
        layoutSubviews()
        bindViewModel()
        
        vm.send(action: .lookup)
    }
    
    func configureSubviews() {
        radioImageView.contentMode = .scaleAspectFit
        radioImageView.tintColor = UIColor(white: 0.2, alpha: 1) //< #262626
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        let retryLookupAction = UIAction { [weak self] _ in
            self?.vm.send(action: .lookup)
        }
        
        retryButton.addAction(retryLookupAction, for: .touchUpInside)
        retryButton.setTitle("Retry to connect server", for: .normal)
    }
    
    func layoutSubviews() {
        view.subviews {
            radioImageView
            indicatorView
            retryButton
        }
        
        view.layout {
            radioImageView.size(200)
            |-indicatorView-|
            |-retryButton-|
        }
        
        radioImageView.centerInContainer()
    }
    
    func bindViewModel() {
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
                
        vm.state.$status
            .map { $0 != .failed }
            .drive(retryButton.rx.isHidden)
            .disposed(by: dbag)
    }
}
