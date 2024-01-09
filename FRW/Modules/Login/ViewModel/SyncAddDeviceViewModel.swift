//
//  AddSyncDeviceViewModel.swift
//  FRW
//
//  Created by cat on 2023/11/30.
//

import Flow
import Foundation
import WalletConnectSign
import WalletConnectUtils

extension SyncAddDeviceViewModel {
    typealias Callback = (Bool) -> ()
}

class SyncAddDeviceViewModel: ObservableObject {
    var model: SyncInfo.DeviceInfo
    private var callback: BrowserAuthzViewModel.Callback?
    
    @Published var result: String = ""
    
    init(with model: SyncInfo.DeviceInfo, callback: @escaping SyncAddDeviceViewModel.Callback) {
        self.model = model
        self.callback = callback
        NotificationCenter.default.addObserver(self, selector: #selector(onTransactionManagerChanged), name: .transactionManagerDidChanged, object: nil)
    }
    
    func addDevice() {
        Task {
            let address = WalletManager.shared.address
            let accountKey = Flow.AccountKey(publicKey: Flow.PublicKey(hex: model.accountKey.publicKey), signAlgo: .ECDSA_P256, hashAlgo: .SHA2_256, weight: 1000)
            do {
                let flowId = try await flow.addKeyToAccount(address: address, accountKey: accountKey, signers: [WalletManager.shared, RemoteConfigManager.shared])
                guard let data = try? JSONEncoder().encode(model) else {
                    return
                }
                let holder = TransactionManager.TransactionHolder(id: flowId, type: .addToken, data: data)
                TransactionManager.shared.newTransaction(holder: holder)
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "restore_account_failed".localized)
            }
        }
    }
    
    @objc private func onTransactionManagerChanged() {
        refreshPanelHolder()
    }
    
    func refreshPanelHolder() {
        if TransactionManager.shared.holders.isEmpty {
            sendSuccessStatus()
            return
        }
    }
    
    func dismiss() {
        Router.dismiss()
    }
    
    func sendSuccessStatus() {
        Task {
            do {
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.syncDevice(self.model))
                if response.httpCode != 200 {
                    log.info("[Sync Device] add device failed. publicKey: \(self.model.accountKey.publicKey)")
                    DispatchQueue.main.async {
                        self.result = "add device failed."
                    }
                    callback?(false)
                } else {
                    DispatchQueue.main.async {
                        self.dismiss()
                    }
                    callback?(true)
                }
            } catch {
                callback?(false)
                log.error("[sync account] error \(error.localizedDescription)")
            }
        }
    }
    
    func sendFaildStatus() {
        callback?(false)
    }
    
    deinit {
        NotificationCenter().removeObserver(self)
    }
}
