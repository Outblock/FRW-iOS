//
//  KeyStoreLoginViewModel.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import Foundation
import Web3Core
import WalletCore

import Flow
import SwiftUI
import FlowWalletKit


class KeyStoreLoginViewModel: ObservableObject {
    @Published var json: String = ""
    @Published var password: String = ""
    @Published var wantedAddress: String = ""
    
    @Published var buttonState: VPrimaryButtonState = .disabled
    
    var userName: String = ""
    
    private var privateKey: FlowWalletKit.PrivateKey?
    @Published var wallet: FlowWalletKit.Wallet? = nil
    
    var p256Response: FlowWalletKit.KeyIndexerResponse? = nil
    var secp256Response: FlowWalletKit.KeyIndexerResponse? = nil
    
    
    private var account: Flow.Account? = nil
    
    
    @MainActor func update(json: String) {
        update()
    }
    
    @MainActor func update(password: String) {
        update()
    }
    
    @MainActor private func update() {
        do {
            let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
            privateKey = try PrivateKey.restore(json: json, password: password, storage: FlowWalletKit.PrivateKey.PKStorage)
            guard let privateKey = privateKey  else {
                return
            }
            wallet = FlowWalletKit.Wallet(type: .key(privateKey), networks: [chainId])
            updateButtonState()
            log.debug("[Import] keystore init success.")
        }catch {
            log.error("[Import] keystore init failed.\(error)")
        }
    }
    
    
    func update(address: String) {
        
    }
    
    private func updateButtonState() {
        buttonState =  (json.isEmpty || password.isEmpty || wallet == nil ) ? .disabled : .enabled
    }
    
    func onSumbit() {
        UIApplication.shared.endEditing()
        Task {
            do {
                try await fetchAllAddresses()
                if wantedAddress.isEmpty {
                    await self.showAllAccounts()
                }else {
                    let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
                    guard let keys = await wallet?.flowAccounts?[chainId] else {
                        return
                    }
                    guard let account = keys.filter({ $0.address.hex == wantedAddress }).first else {
                        return
                    }
                    selectedAccount(by: account)
                }
            }catch {
                
            }
        }
    }
    
    // fetch all addresses of Public Key
    func fetchAllAddresses() async throws {
        HUD.loading()
        do {
            _ = try await wallet?.fetchAllNetworkAccounts()
        }catch {
            log.error("\(error.localizedDescription)")
        }
        
        HUD.dismissLoading()
        
//        log.info("[Import] get p256PubKey,\(String(describing: p256PublicKey))")
//        let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
//        if let p256PubKey = p256PublicKey {
//            p256Response = try await FlowWalletKit.Network.findAccount(publicKey: p256PubKey, chainID: chainId)
//            let p256AddrStr = p256Response?.accounts.reduce("", { $0 + $1.address + "-"})
//            log.info("[Import] get p256 public key.\(String(describing: p256AddrStr))")
//        }
//        
//        log.info("[Import] get secp256PubKey,\(String(describing: secp256PublicKey))")
//        if let secp256PubKey = secp256PublicKey {
//            secp256Response = try await FlowWalletKit.Network.findAccount(publicKey: secp256PubKey, chainID: chainId)
//            let secp256AddrStr = secp256Response?.accounts.reduce("", { $0 + $1.address + "-"})
//            log.info("[Import] get secp256 public key.\(String(describing: secp256AddrStr))")
//        }
//        HUD.dismissLoading()
    }
    
    
    // select one address
    @MainActor private func showAllAccounts() {
        let chainId = LocalUserDefaults.shared.flowNetwork.toFlowType()
        let list = wallet?.flowAccounts?[chainId] ?? []
        
        //TODO: 换成 .halfSheet(showSheet: $vm.showConfirmView, sheetView: {
        
        let viewModel = ImportAccountsViewModel(list: list) { [weak self] account in
            log.info("[Import] selected address: \(account.address.hex)")
            self?.selectedAccount(by: account)
        }
        Router.route(to: RouteMap.RestoreLogin.importAddress(viewModel))
    }
    
    func selectedAccount(by account: Flow.Account) {
        self.account = account
        self.createUserName()
    }
    
    func createUserName() {
        let viewModel = ImportUserNameViewModel { name in
            if !name.isEmpty {
                self.checkPublicKey(with: name)
            }
        }
        Router.route(to: RouteMap.RestoreLogin.importUserName(viewModel))
    }
    
    func checkPublicKey(with userName: String) {
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
                    try await UserManager.shared.importLogin(by: address, userName: userName, flowKey: selectedKey, privateKey: privateKey )
                }else if response.httpCode == 200 {
                    try await UserManager.shared.importLogin(by: address, userName: userName, flowKey: selectedKey, privateKey: privateKey, isImport: true)
                    Router.popToRoot()
                }
                HUD.dismissLoading()
            }
            catch  {
                if let code = error.moyaCode() {
                    if code == 409 {
                        do {
                            try await UserManager.shared.importLogin(by: address, userName: userName, flowKey: selectedKey, privateKey: privateKey)
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
    
//    private func checkOwn(address: String) {
//        guard let publicKey = account.publicKey, let privateKey = privateKey else {
//            log.error("[Import] public key is empty.")
//            return
//        }
//        Task() {
//            HUD.loading()
//            do {
//                let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.checkimport(publicKey))
//                if response.httpCode == 409 {
//                    try await UserManager.shared.restoreLogin(account: account, pkWallet: privateKey)
//                }else if response.httpCode == 200 {
//                    try await UserManager.shared.restoreLogin(account: account, pkWallet: privateKey, isImport: true)
//                    Router.popToRoot()
//                }
//                HUD.dismissLoading()
//            }
//            catch  {
//                if let code = error.moyaCode() {
//                    if code == 409 {
//                        do {
//                            try await UserManager.shared.restoreLogin(account: account, pkWallet: privateKey)
//                            Router.popToRoot()
//                        }catch {
//                            log.error("[Import] login 409 :\(error)")
//                        }
//                        
//                    }
//                }
//                log.error("[Import] check public key own error:\(error)")
//                HUD.dismissLoading()
//            }
//        }
//    }
}

extension KeyStoreLoginViewModel {
    private var p256PublicKey: String? {
        return (try? privateKey?.publicKey(signAlgo: .ECDSA_P256))?.hexValue.dropPrefix("04")
    }
    
    private var secp256PublicKey: String? {
        return (try? privateKey?.publicKey(signAlgo: .ECDSA_SECP256k1))?.hexValue.dropPrefix("04")
    }
}

// MARK: - Model
struct Keystore: Codable {
    var address: String?
    var crypto: CryptoParamsV3
    var id: String?
    var version: Int
}

struct ImportAccountInfo {
    
    let address: String?
    let weight: Int?
    let keyId: Int?
    let publicKey: String?
    let signAlgo: Flow.SignatureAlgorithm
    let hashAlgo: Flow.HashAlgorithm = .SHA2_256
}
