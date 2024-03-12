//
//  DevicesInfoViewModel.swift
//  FRW
//
//  Created by cat on 2024/3/12.
//

import SwiftUI

class DevicesInfoViewModel: ObservableObject {
    @Published var showRemoveTipView = false
    @Published var showRevokeButton = false
    var model: DeviceInfoModel
    
    init(model: DeviceInfoModel) {
        self.model = model
        if let deviceId = self.model.id {
            if DeviceManager.shared.isCurrent(deviceId: deviceId) {
                self.showRevokeButton = false
            } else if let accountkey = DeviceManager.shared.findFlowAccount(deviceId: deviceId) {
                self.showRevokeButton = true
            }else {
                self.showRevokeButton = false
            }
        }else {
            showRevokeButton = false
        }
        
    }
    
    func onRevoke() {
        if showRemoveTipView {
            showRemoveTipView = false
        }
        withAnimation(.easeOut(duration: 0.2)) {
            showRemoveTipView = true
        }
    }
    
    func onCancel() {
        showRemoveTipView = false
    }
    
    func revokeAction() {
        guard let deviceId = self.model.id else {
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }
        let isCurrent = DeviceManager.shared.isCurrent(deviceId: deviceId)
        guard !isCurrent else {
            HUD.info(title: "account_key_current_tips".localized)
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }
        
        guard let accountKey = DeviceManager.shared.findFlowAccount(deviceId: deviceId) else {
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }
        guard let cur = WalletManager.shared.getCurrentPublicKey(), cur == accountKey.publicKey.description else {
            HUD.info(title: "account_key_current_tips".localized)
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }
        
        Task {
            HUD.loading()
            let res = try await AccountKeyManager.revokeKey(at: accountKey.index)
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            Router.pop()
            HUD.dismissLoading()
        }
    }
}
