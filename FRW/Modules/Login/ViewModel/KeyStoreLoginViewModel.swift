//
//  KeyStoreLoginViewModel.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import Foundation
import Web3Core
import WalletCore
import FlowWalletKit
import Flow

class KeyStoreLoginViewModel: ObservableObject {
    @Published var json: String = ""
    @Published var password: String = ""
    @Published var address: String = ""
    
    @Published var buttonState: VPrimaryButtonState = .disabled
    
    var p256Accounts: [ImportAccountInfo]? = []
    var secp256Accounts: [ImportAccountInfo]? = []
    
    private var pkWallet: PKWallet?
    
    
    func update(json: String) {
        update()
    }
    
    func update(password: String) {
        update()
    }
    
    private func update() {
        do {
            pkWallet = try PKWallet.restore(json: json, password: password, storage: PKWallet.PKStorage)
            updateButtonState()
            log.debug("[Import] keystore init success.")
        }catch {
            log.error("[Import] keystore init failed.")
        }
    }
    
    
    func update(address: String) {
        
    }
    
    private func updateButtonState() {
        buttonState =  (json.isEmpty || password.isEmpty || pkWallet == nil) ? .disabled : .enabled
    }
    
    func onSumbit() {
        
        guard let privateKey = pkWallet?.pk  else {
            return
        }
        Task {
            do {
                HUD.loading()
                log.info("[Import] start")
                // pk store
                log.info("[Import] get private key")
                
                let p256PubKey = (try? pkWallet?.publicKey(signAlgo: .ECDSA_P256))?.hexValue.dropPrefix("04")
                
                log.info("[Import] get p256PubKey,\(String(describing: p256PubKey))")
                
                if let p256PubKey = p256PubKey {
                    let p256response = try await self.fetchAddress(from: p256PubKey)
                    p256Accounts = p256response.accounts?.map({ ImportAccountInfo(address: $0.address, weight: $0.weight, keyId: $0.keyId, publicKey: p256response.publicKey, signAlgo: .ECDSA_P256) })
                    let p256AddrStr = p256Accounts?.reduce("", { $0 + ($1.address ?? "") + "-"})
                    log.info("[Import] get p256 public key.\(String(describing: p256AddrStr))")
                }
                
                let secp256PubKey = (try? pkWallet?.publicKey(signAlgo: .ECDSA_SECP256k1))?.hexValue.dropPrefix("04")
                log.info("[Import] get secp256PubKey,\(String(describing: secp256PubKey))")
                if let secp256PubKey = secp256PubKey {
                    let secp256response = try await fetchAddress(from: secp256PubKey)
                    secp256Accounts = secp256response.accounts?.map({ ImportAccountInfo(address: $0.address, weight: $0.weight, keyId: $0.keyId, publicKey: secp256response.publicKey, signAlgo: .ECDSA_SECP256k1) })
                    let secp256AddrStr = secp256Accounts?.reduce("", { $0 + ($1.address ?? "") + "-"})
                    log.info("[Import] get secp256 public key.\(String(describing: secp256AddrStr))")
                }
                
                
                DispatchQueue.main.async {
                    self.onSelectedAddress()
                    HUD.dismissLoading()
                }
                
            }catch {
                log.error("[Import] submit failed. \(error)")
            }
        }
        
    }
    
    private func fetchAddress(from publicKey: String) async throws -> UserManager.AccountResponse {
        var response: UserManager.AccountResponse = try await Network.requestWithRawModel(FRWAPI.Utils.flowAddress(publicKey))
        let list = response.accounts?.filter { ($0.weight ?? 0) >= 1000 && $0.address != nil }
        response.accounts = list
        return response
    }
    
    private func onSelectedAddress() {
        let list = (p256Accounts ?? []) + (secp256Accounts ?? [])
        let viewModel = ImportAccountsViewModel(list: list) { [weak self] account in
            log.info("[Import] selected address: \(account.address ?? "")")
            self?.checkOwn(account: account)
        }
        Router.route(to: RouteMap.RestoreLogin.importAddress(viewModel))
    }
    
    private func checkOwn(account: ImportAccountInfo) {
        guard let publicKey = account.publicKey, let pkWallet = pkWallet else {
            log.error("[Import] public key is empty.")
            return
        }
        Task() {
            do {
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.checkimport(publicKey))
                if response.httpCode == 409 {
                    try await UserManager.shared.restoreLogin(account: account, pkWallet: pkWallet)
                }else if response.httpCode == 200 {
                    try await UserManager.shared.restoreLogin(account: account, pkWallet: pkWallet, isImport: true)
                    Router.popToRoot()
                }
            }
            catch  {
                if let code = error.moyaCode() {
                    if code == 409 {
                        do {
                            try await UserManager.shared.restoreLogin(account: account, pkWallet: pkWallet)
                            Router.popToRoot()
                        }catch {
                            log.error("[Import] login 409 :\(error)")
                        }
                        
                    }
                }
                log.error("[Import] check public key own error:\(error)")
            }
        }
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
