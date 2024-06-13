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
    private var ignoreMoveHint: Bool = false
    
    var allowMoveAssets: Bool {
        return LocalUserDefaults.shared.flowNetwork == .previewnet
    }
    
    private init(){}
    
    func startBrowserWithMoveAssets(callback: @escaping EmptyClosure) {
        if !allowMoveAssets {
            callback()
            return
        }
        self.browserCallback = callback
        if ignoreMoveHint {
            endBrowser()
        }else {
            Router.route(to: RouteMap.Wallet.moveAssets)
            ignoreMoveHint = true
        }
    }
    
    func endBrowser() {
        self.browserCallback?()
        self.browserCallback = nil
    }
    
    func reset() {
        ignoreMoveHint = false
    }
}

extension MoveAssetsAction {
    
}
