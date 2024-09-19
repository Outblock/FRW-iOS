//
//  SyncConfirmViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/1.
//

import Flow
import FlowWalletKit
import Foundation
import WalletConnectSign
import WalletConnectUtils

enum SyncAccountStatus {
    case idle, loading, success, syncSuccess
}

class SyncConfirmViewModel: ObservableObject {
    @Published var status: SyncAccountStatus = .idle
    @Published var isPresented: Bool = false
    
    var userId: String
    
    init(userId: String) {
        self.userId = userId
        NotificationCenter.default.addObserver(self, selector: #selector(self.onSyncStatusChanged), name: .syncDeviceStatusDidChanged, object: nil)
    }
    
    func onAddDevice() {
        self.isPresented = true
        self.status = .loading
        Task {
            do {
                guard let currentSession = WalletConnectManager.shared.findSession(method: FCLWalletConnectMethod.accountInfo.rawValue) else {
                    return
                }
                let methods: String = FCLWalletConnectMethod.addDeviceInfo.rawValue
                let blockchain = Sign.FlowWallet.blockchain
                
                let params = try await WalletConnectSyncDevice.packageDeviceInfo(userId: self.userId)
                let request = try Request(topic: currentSession.topic, method: methods, params: params, chainId: blockchain)
                try await Sign.instance.request(params: request)
                WalletConnectManager.shared.currentRequest = request
            }
            catch {
                DispatchQueue.main.async {
                    self.status = .idle
                }
                log.error("[sync account] error \(error.localizedDescription)")
                HUD.error(title: "sync_confirm_failed".localized)
            }
        }
    }
    
    @objc private func onSyncStatusChanged(note: Notification) {
        guard let result = note.object as? WalletConnectSyncDevice.SyncResult else { return }
        // 登录
        switch result {
        case .success:
            Task {
                do {
                    try await UserManager.shared.restoreLogin(userId: self.userId)
                    DispatchQueue.main.async {
                        self.status = .success
                    }
                }
                catch {
                    log.error("[Sync Device] login with \(self.userId) failed. reason:\(error.localizedDescription)")
                }
            }
        case .failed(let msg):
            HUD.error(title: "sync_confirm_failed".localized)
        }
    }
}
