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
    
    var p256Accounts: [String]? = []
    var secp256Accounts: [String]? = []
    
    private var privateKey: FlowWalletKit.PrivateKey?
    
    private var account: Flow.Account? = nil
    
    
    func update(json: String) {
        update()
    }
    
    func update(password: String) {
        update()
    }
    
    private func update() {
        do {
            privateKey = try PrivateKey.restore(json: json, password: password, storage: FlowWalletKit.PrivateKey.PKStorage)
            updateButtonState()
            log.debug("[Import] keystore init success.")
        }catch {
            log.error("[Import] keystore init failed.\(error)")
        }
    }
    
    
    func update(address: String) {
        
    }
    
    private func updateButtonState() {
        buttonState =  (json.isEmpty || password.isEmpty || privateKey == nil || userName.isEmpty) ? .disabled : .enabled
    }
    
    func onSumbit() {
        /*
         1. 解析JSON
         2. 地址
            1. 如果地址是空，则根据 public key 请求地址
            2. 如果地址非空，则获取地址 对应的 account 信息
         3. 根据选定的地址请求 account 信息
         4. 用户名信息
         4. 请求服务器数据
            1. 200
            2. 409
         */
        UIApplication.shared.endEditing()
        if wantedAddress.isEmpty {
            Task {
                do {
                    try await fetchAllAddresses()
                    self.onSelectedAddress()
                }
            }
        }else {
            fetchAccount(by: wantedAddress)
        }
        
        
    }
    
    // fetch all addresses of Public Key
    func fetchAllAddresses() async throws {
        HUD.loading()
        
        log.info("[Import] get p256PubKey,\(String(describing: p256PublicKey))")
        
        if let p256PubKey = p256PublicKey {
            p256Accounts = try? await self.fetchAddress(from: p256PubKey)
            let p256AddrStr = p256Accounts?.reduce("", { $0 + $1 + "-"})
            log.info("[Import] get p256 public key.\(String(describing: p256AddrStr))")
        }
        
        log.info("[Import] get secp256PubKey,\(String(describing: secp256PublicKey))")
        if let secp256PubKey = secp256PublicKey {
            secp256Accounts = try? await fetchAddress(from: secp256PubKey)
            let secp256AddrStr = secp256Accounts?.reduce("", { $0 + $1 + "-"})
            log.info("[Import] get secp256 public key.\(String(describing: secp256AddrStr))")
        }
        HUD.dismissLoading()
    }
    
    private func fetchAddress(from publicKey: String) async throws -> [String] {
        
        let accounts: [KeyIndexerResponse.Account] = try await FlowWalletKit.Network.findAccountByKey(publicKey: publicKey, chainID: LocalUserDefaults.shared.flowNetwork.toFlowType())
        let addresses = accounts.map { $0.address }
        return addresses

    }
    // select one address
    private func onSelectedAddress() {
        //TODO: 换成 .halfSheet(showSheet: $vm.showConfirmView, sheetView: {
        let list = (p256Accounts ?? []) + (secp256Accounts ?? [])
        let viewModel = ImportAccountsViewModel(list: list) { [weak self] address in
            log.info("[Import] selected address: \(address)")
            self?.fetchAccount(by: address)
        }
        Router.route(to: RouteMap.RestoreLogin.importAddress(viewModel))
    }
    
    func fetchAccount(by address: String) {
        Task {
            do {
                self.account = nil
                self.account = try await Flow.shared.accessAPI.getAccountAtLatestBlock(address: address)
                self.createUserName()
            }
            catch {
                log.error("[Import] fetch account error:\(error.localizedDescription)")
            }
        }
        
    }
    
    func createUserName() {
        let viewModel = ImportUserNameViewModel { name in
            if !name.isEmpty {
                
            }
        }
        Router.route(to: RouteMap.RestoreLogin.importUserName(viewModel))
    }
    
    func checkPublicKey(with userName: String) {
        let keys = account?.keys.filter({ $0.publicKey.description == p256PublicKey || $0.publicKey.description == secp256PublicKey })
        guard let selectedKey = keys?.first,
        let address = account?.address.hex,
                let privateKey = privateKey
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
                    try await UserManager.shared.restoreLogin(by: address, userName: userName, flowKey: selectedKey, privateKey: privateKey )
                }else if response.httpCode == 200 {
                    try await UserManager.shared.restoreLogin(by: address, userName: userName, flowKey: selectedKey, privateKey: privateKey, isImport: true)
                    Router.popToRoot()
                }
                HUD.dismissLoading()
            }
            catch  {
                if let code = error.moyaCode() {
                    if code == 409 {
                        do {
                            try await UserManager.shared.restoreLogin(by: address, userName: userName, flowKey: selectedKey, privateKey: privateKey)
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
