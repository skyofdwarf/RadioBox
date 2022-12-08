//
//  SettingsViewModel.swift
//  Radiow
//
//  Created by YEONGJUNG KIM on 2022/11/15.
//  Copyright © 2022 dwarfini. All rights reserved.
//

import UIKit
import RDXVM
import RadioBrowser
import RxSwift

enum SettingsAction {
}

enum SettingsMutation {
    case fetching(Bool)
}
enum SettingsEvent {
    case coordinate(SettingsCoordinator.Location)
}

extension SettingsEvent: Coordinating {
    var location: SettingsCoordinator.Location? {
        switch self {
        case .coordinate(let location): return location
        default: return nil
        }
    }
}

struct SettingsState {
    @Drived var fetching: Bool = false
    
    @Drived var htmlContent: String
}

fileprivate let defualtHtml: String = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=0">
    <title>Radiow</title>
    <style>
    * {
        -webkit-tap-highlight-color:rgba(255,255,255,0);
        -webkit-touch-callout: none;
        -webkit-user-select: none;
        user-select: none;
    }
    pre {
        white-space: pre-wrap;
    }
    body {
        font: -apple-system-body;
    }
    </style>
</head>
<body>
    <h2>About</h2>
    <p><strong>Radiow</strong><span style="font-size: 0.7em;">(v${APP_VERSION})</span></sub> is a radio app for all who want to listen to world radio waves.</p>
    <p>All radio stations listed in Radiow are from <strong><a href="https://www.radio-browser.info">RadioBrowser</a></strong>.</p>
</body>
</html>
"""

final class SettingsViewModel: CoordinatingViewModel<SettingsAction, SettingsMutation, SettingsEvent, SettingsState> {
    init<C: Coordinator>(coordinator: C) where C.Location == Event.Location {
        func loadSettings() -> String {
            guard let url = Bundle.main.url(forResource: "settings", withExtension: "html"),
                  let html = try? String(contentsOf: url, encoding: .utf8)
            else {
                return defualtHtml
            }
            
            guard let range = html.range(of: "${APP_VERSION}") else {
                return html
            }
            
            let version = UIApplication.shared.version
            
            return html.replacingCharacters(in: range, with: "\(version)")
        }
        
        super.init(coordinator: coordinator, state: State(htmlContent: loadSettings()))
    }
    
    override func react(action: Action, state: State) -> Observable<Reaction> {
        switch action {
        }
    }
    
    override  func reduce(mutation: Mutation, state: inout State) {
        switch mutation {
        case .fetching(let fetching):
            state.fetching = fetching
        }
    }
}
