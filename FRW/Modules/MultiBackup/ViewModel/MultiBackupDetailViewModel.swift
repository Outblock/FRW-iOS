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
            
            let res = try await AccountKeyManager.revokeKey(at: keyIndex)
            if res {
                try await MultiBackupManager.shared.removeItem(with: type)
                DispatchQueue.main.async {
                    self.showRemoveTipView = false
                }
                Router.pop()
            }
            HUD.dismissLoading()
        }
    }
    
}
