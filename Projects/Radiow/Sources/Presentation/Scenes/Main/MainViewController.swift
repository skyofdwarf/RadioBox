//
//  MainViewController.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UITabBarController {
    private(set) var dbag = DisposeBag()
    
    let vm: MainViewModel
    
    override var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }
    
    init(vm: MainViewModel) {
        self.vm = vm
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
        
        bindViewModel()
    }
    
    func bindViewModel() {
        vm.event
            .emit(with: self) { this, event in
                this.processEvent(event)
            }
            .disposed(by: dbag)
    }
    
    func processEvent(_ event: MainEvent) {
        switch event {
        case .appEvent(let appEvent):
            processAppEvent(appEvent)
        default: break
        }
    }
    
    func processAppEvent(_ appEvent: AppEvent) {
        switch appEvent {
        case .appUpdated:
            let alert = UIAlertController(title: "Radiow", message: "New update available", preferredStyle: .alert).then {
                $0.addAction(UIAlertAction(title: "Update", style: .default, handler: { [weak self] _ in
                    self?.vm.send(action: .goToAppstore)
                }))
                $0.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            }
            
            present(alert, animated: true)
        default: break
        }
    }
}
