//
//  AddSyncDeviceViewModel.swift
//  FRW
//
//  Created by cat on 2023/11/30.
//

import Foundation
import Flow
import WalletConnectSign
import WalletConnectUtils

class SyncAddDeviceViewModel: ObservableObject {
    
    var requstParam: RegisterRequest?
    @Published var result: String = ""
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(onTransactionManagerChanged), name: .transactionManagerDidChanged, object: nil)

    }
    
    func addDevice(with model: RegisterRequest) {
        self.requstParam = model
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
            }catch {
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
                guard let apiParam = self.requstParam else { return  }
                do {
                    let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.syncDevice(apiParam))
                    if response.httpCode != 200 {
                        DispatchQueue.main.async {
                            self.result = "add device failed."
                        }
                        return
                    }
                }catch {
                    print(error)
                }
                
                
                log.info("[Sync Device] add device success. publicKey: \(apiParam.accountKey.publicKey)")
                guard let currentSession = WalletConnectManager.shared.findSession(method: FCLWalletConnectMethod.accountInfo.rawValue) else {
                    return
                }
                let methods: String = FCLWalletConnectMethod.addDeviceInfo.rawValue
                let blockchain = Sign.FlowWallet.blockchain

                let dic = [
                    "method": FCLWalletConnectMethod.addDeviceInfo.rawValue,
                    "data": "",
                    "status": "3",
                    "message": ""
                ]
                let params = AnyCodable(dic)
                let request = Request(topic: currentSession.topic, method: methods, params: params, chainId: blockchain)
                try await Sign.instance.request(params: request)
                DispatchQueue.main.async {
                    self.dismiss()
                    
                }
            }
            catch {
                log.error("[sync account] error \(error.localizedDescription)")
            }
        }
    }
    
    func sendFaildStatus() {
        
    }
    
}
