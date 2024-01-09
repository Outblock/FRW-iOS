//
//  MultiBackupDetailViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/9.
//

import Flow
import SwiftUI

class MultiBackupDetailViewModel: ObservableObject {
    var item: KeyDeviceModel
    
    @Published var showRemoveTipView = false
    
    init(item: KeyDeviceModel) {
        self.item = item
    }
    
    func onDelete() {
        if showRemoveTipView {
            showRemoveTipView = false
        }
        withAnimation(.easeOut(duration: 0.2)) {
            showRemoveTipView = true
        }
    }
    
    func onCancelTip() {
        showRemoveTipView = false
    }
    
    func deleteMultiBackup() {
        guard let keyIndex = item.backupInfo?.keyIndex, let type = item.multiBackupType() else { return }
        
        Task {
            HUD.loading()
            await revokeKey(at: keyIndex)
            try await MultiBackupManager.shared.removeItem(with: type)
            showRemoveTipView = false
            HUD.dismissLoading()
            Router.pop()
        }
    }
    
    private func revokeKey(at index: Int) async {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            HUD.info(title: "account_key_fail_tips".localized)
            return
        }
        do {
            let flowId = try await FlowNetwork.revokeAccountKey(by: index, at: Flow.Address(hex: address))
            log.debug("revoke flow id:\(flowId)")
            
        } catch {
            HUD.error(title: "account_key_fail_tips".localized)
            log.error("revoke key: \(error)")
        }
    }
}
