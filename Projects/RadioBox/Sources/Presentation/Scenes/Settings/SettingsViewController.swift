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
import WebKit

class SettingsViewController: UIViewController {
    let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
    let webView = WKWebView(frame: .zero)
    
    var vm: SettingsViewModel!
    var dbag = DisposeBag()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        title = "RadioBox"
        
        tabBarItem = UITabBarItem(title: "About",
                                  image: UIImage(systemName: "info.circle"),
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
    }
    
    func configureSubviews() {
        indicatorView.color = .red
        indicatorView.hidesWhenStopped = true
        
        webView.navigationDelegate = self
    }
    
    func layoutSubviews() {
        view.subviews {
            webView
            indicatorView
        }
        
        indicatorView.centerInContainer()
        webView.fillContainer()
    }
    
    func bindViewModel() {
        vm.state.$fetching
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: dbag)
        
        vm.state.$htmlContent
            .drive { [weak self] html in
                print(">> load html")
                self?.webView.loadHTMLString(html, baseURL: nil)
            }
            .disposed(by: dbag)
    }
}

extension SettingsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow, preferences)
            return
        }
        
        let allowed = [ "about:blank" ]
        let allows = allowed.contains(url.absoluteString)
        
        if !allows {
            UIApplication.shared.open(url)
        }
        
        decisionHandler(allows ? .allow: .cancel, preferences)
    }
}
