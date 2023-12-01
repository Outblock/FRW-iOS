//
//  SyncConfirmViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/1.
//

import Foundation
import WalletConnectSign
import WalletConnectUtils
import FlowWalletCore
import Flow

enum SyncAccountStatus {
    case idle,loading,success, syncSuccess
}

class SyncConfirmViewModel: ObservableObject {
    
    @Published var status: SyncAccountStatus = .idle
    @Published var isPresented: Bool = false
    
    var userId: String
    
    init(userId: String) {
        self.userId = userId
        NotificationCenter.default.addObserver(self, selector: #selector(onSyncStatusChanged), name: .syncDeviceStatusDidChanged, object: nil)
    }
    
    func onAddDevice()  {
        self.isPresented = true
        self.status = .loading
        Task {
            
            do {
                guard let currentSession = WalletConnectManager.shared.findSession(method: FCLWalletConnectMethod.accountInfo.rawValue) else {
                    return
                }
                let methods: String = FCLWalletConnectMethod.addDeviceInfo.rawValue
                let blockchain = Sign.FlowWallet.blockchain
                
                let sec = try WallectSecureEnclave()
                let key = try sec.accountKey()
                
                
                if IPManager.shared.info == nil {
                    await IPManager.shared.fetch()
                }
                let requestParam = RegisterRequest(username: "", accountKey: key.toCodableModel(), deviceInfo: IPManager.shared.toParams())
                
                let dic = [
                    "method": FCLWalletConnectMethod.addDeviceInfo.rawValue,
                    "data": try requestParam.asJSONEncodedString(),
                    "status": "2",
                    "message": ""
                ]
                let params = AnyCodable(dic)
                let request = Request(topic: currentSession.topic, method: methods, params: params, chainId: blockchain)
                try await Sign.instance.request(params: request)

                try WallectSecureEnclave.Store.store(key: userId, value: sec.key.privateKey!.dataRepresentation)

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
        print(note)
        // 登录
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
        
    }
}
