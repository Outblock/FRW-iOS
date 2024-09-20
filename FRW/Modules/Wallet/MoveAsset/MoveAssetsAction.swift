//
//  MoveAssetsAction.swift
//  FRW
//
//  Created by cat on 2024/6/13.
//

import Foundation

class MoveAssetsAction {
    static let shared = MoveAssetsAction()
    
    private var browserCallback: EmptyClosure?
    private var appName: String? = nil
    
    var allowMoveAssets: Bool {
        return true
    }
    
    var showNote: String? {
        guard let name = appName, !name.isEmpty else {
            return nil
        }
        return "move_asset_browser_title_x".localized(name)
    }
    
    private init(){}
    
    func startBrowserWithMoveAssets(appName: String?, callback: @escaping EmptyClosure) {
        
        if !allowMoveAssets || !LocalUserDefaults.shared.showMoveAssetOnBrowser {
            callback()
            return
        }
        self.appName = appName
        self.browserCallback = callback
        Router.route(to: RouteMap.Wallet.moveAssets)
    }
    
    func endBrowser() {
        self.browserCallback?()
        self.browserCallback = nil
        self.appName = ""
    }
        
    var showCheckOnMoveAsset: Bool {
        browserCallback != nil
    }
}

extension MoveAssetsAction {
    
}
