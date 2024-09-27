//
//  PrivateKeyLoginViewModel.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import Foundation
import FlowWalletKit
import Flow
import UIKit
import CryptoKit
import WalletCore

class PrivateKeyLoginViewModel: ObservableObject {
    @Published var key: String = ""
    @Published var wantedAddress: String = ""
    @Published var buttonState: VPrimaryButtonState = .disabled
    
    var userName: String = ""
    
    private var privateKey: FlowWalletKit.PrivateKey?
    var wallet: FlowWalletKit.Wallet? = nil
    private var account: Flow.Account? = nil
    
    @MainActor func update(key: String) {
        update()
    }
    
    @MainActor func update(address: String) {
        update()
    }
    
    @MainActor private func update() {
        updateButtonState()
    }
    
    private func updateButtonState() {
        buttonState =  (key.isEmpty ) ? .disabled : .enabled
    }
    
    func onSumbit() {
        UIApplication.shared.endEditing()
        HUD.loading()
        Task {
            do {
                let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
                guard let data = Data(hexString: key.stripHexPrefix()) else {
                    return
                }
                
                privateKey = try PrivateKey.restore(secret: data, storage: FlowWalletKit.PrivateKey.PKStorage)
                guard let privateKey = privateKey  else {
                    return
                }
                wallet = FlowWalletKit.Wallet(type: .key(privateKey), networks: [chainId])
                
                try await fetchAllAddresses()
                HUD.dismissLoading()
                if wantedAddress.isEmpty {
                    await self.showAllAccounts()
                }else {
                    let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
                    guard let keys = wallet?.flowAccounts?[chainId] else {
                        return
                    }
                    guard let account = keys.filter({ $0.address.hex == wantedAddress }).first else {
                        return
                    }
                    selectedAccount(by: account)
                }
            }catch {
                HUD.dismissLoading()
            }
        }
    }
    
    func fetchAllAddresses() async throws {
        
        do {
            _ = try await wallet?.fetchAllNetworkAccounts()
        }catch {
            log.error("\(error.localizedDescription)")
        }
        
    }
    
    
    // select one address
    @MainActor private func showAllAccounts() {
        let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
        let list = wallet?.flowAccounts?[chainId] ?? []
        
        let viewModel = ImportAccountsViewModel(list: list) { [weak self] account in
            log.info("[Import] selected address: \(account.address.hex)")
            self?.selectedAccount(by: account)
        }
        Router.route(to: RouteMap.RestoreLogin.importAddress(viewModel))
    }
    
    func selectedAccount(by account: Flow.Account) {
        self.account = account
        checkPublicKey()
    }
    
    func createUserName(callback:@escaping (String)->()) {
        let viewModel = ImportUserNameViewModel {  name in
            if !name.isEmpty {
                callback(name)
            }
        }
        Router.route(to: RouteMap.RestoreLogin.importUserName(viewModel))
    }
    
    func checkPublicKey() {
        let keys = account?.keys.filter({ $0.publicKey.description == p256PublicKey || $0.publicKey.description == secp256PublicKey })
        guard let selectedKey = keys?.first,
        let address = account?.address.hex, let privateKey = privateKey
        else {
            log.error("[Import] keys of account not match the public:\(String(describing: p256PublicKey)) or \(String(describing: secp256PublicKey)) ")
            return
        }
        Task {
            HUD.loading()
            do {
                let publicKey = selectedKey.publicKey.description
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.checkimport(publicKey))
                if response.httpCode == 409 {
                    try await UserManager.shared.importLogin(by: address, userName: "", flowKey: selectedKey, privateKey: privateKey )
                }else if response.httpCode == 200 {
                    createUserName() { name in
                        Task {
                            try await UserManager.shared.importLogin(by: address, userName: self.userName, flowKey: selectedKey, privateKey: privateKey, isImport: true)
                            Router.popToRoot()
                        }
                    }
                }
                HUD.dismissLoading()
            }
            catch  {
                if let code = error.moyaCode() {
                    if code == 409 {
                        do {
                            try await UserManager.shared.importLogin(by: address, userName: "", flowKey: selectedKey, privateKey: privateKey)
                            Router.popToRoot()
                        }catch {
                            log.error("[Import] login 409 :\(error)")
                        }
                        
                    }
                }
                log.error("[Import] check public key own error:\(error)")
                HUD.dismissLoading()
            }
        }
    }
    
    
    
}

extension PrivateKeyLoginViewModel {
    private var p256PublicKey: String? {
        return (try? privateKey?.publicKey(signAlgo: .ECDSA_P256))?.hexValue.dropPrefix("04")
    }
    
    private var secp256PublicKey: String? {
        return (try? privateKey?.publicKey(signAlgo: .ECDSA_SECP256k1))?.hexValue.dropPrefix("04")
    }
}
