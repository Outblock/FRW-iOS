//
//  KeyStoreLoginViewModel.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import Foundation
import Web3Core
import WalletCore

class KeyStoreLoginViewModel: ObservableObject {
    @Published var json: String = ""
    @Published var password: String = ""
    @Published var address: String = ""
    
    @Published var buttonState: VPrimaryButtonState = .disabled
    
    var p256Accounts: [ImportAccountInfo]? = []
    var secp256Accounts: [ImportAccountInfo]? = []
    var privateKey: WalletCore.PrivateKey?
    
    private var keystore: KeystoreParamsV3?
    
    
    func update(json: String) {
        keystore = nil
        guard let data = json.data(using: .utf8) else {
            return
        }
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let adapter = try jsonDecoder.decode(Keystore.self, from: data)
            keystore = KeystoreParamsV3(address: adapter.address, crypto: adapter.crypto, id: adapter.id ?? "", version: adapter.version)
            updateButtonState()
            log.debug("[Import] keystore init success.")
        }catch {
            log.error("[Import] keystore init failed.\(error)")
        }
    }
    
    func update(password: String) {
        updateButtonState()
    }
    
    func update(address: String) {
        
    }
    
    private func updateButtonState() {
        buttonState =  (json.isEmpty || password.isEmpty || keystore == nil) ? .disabled : .enabled
    }
    
    func onSumbit() {
        
        guard let curretnKeyStore = keystore,let target = EthereumKeystoreV3(curretnKeyStore), let address = target.getAddress() else {
            return
        }
        Task {
            do {
                HUD.loading()
                log.info("[Import] start")
                // pk store
                let data = try target.UNSAFE_getPrivateKeyData(password: password, account: address)
                
                privateKey = WalletCore.PrivateKey(data: data)
                log.info("[Import] get private key")
                let p256PubKey = privateKey?.getPublicKeyNist256p1().uncompressed.data.hexValue.dropPrefix("04")
                let secp256PubKey = privateKey?.getPublicKeySecp256k1(compressed: false).data.hexValue.dropPrefix("04")
                log.info("[Import] get public key,\(String(describing: p256PubKey))\n \(String(describing: secp256PubKey))")
                if let p256PubKey = p256PubKey {
                    let response = try await fetchAddress(from: p256PubKey)
                    p256Accounts = response.accounts?.map({ ImportAccountInfo(address: $0.address, weight: $0.weight, keyId: $0.keyId, publicKey: response.publicKey, publicKeyType: .nist256p1) })
                    let addrStr = p256Accounts?.reduce("", { $0 + ($1.address ?? "") + "-"})
                    log.info("[Import] get p256 public key.\(String(describing: addrStr))")
                }
                
                if let secp256PubKey = secp256PubKey {
                    let response = try await fetchAddress(from: secp256PubKey)
                    secp256Accounts = response.accounts?.map({ ImportAccountInfo(address: $0.address, weight: $0.weight, keyId: $0.keyId, publicKey: response.publicKey, publicKeyType: .secp256k1) })
                    let addrStr = secp256Accounts?.reduce("", { $0 + ($1.address ?? "") + "-"})
                    log.info("[Import] get secp256 public key.\(String(describing: addrStr))")
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
        guard let publicKey = account.publicKey, let privateKey = privateKey else {
            log.error("[Import] public key is empty.")
            return
        }
        Task {
            do {
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.User.checkimport(publicKey))
                if response.httpCode == 409 {
                    try await UserManager.shared.restoreLogin(account: account, privateKey: privateKey)
                }else if response.httpCode == 200 {
                    try await UserManager.shared.restoreLogin(account: account, privateKey: privateKey, isImport: true)
                }
            }
            catch {
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
    let publicKeyType: WalletCore.PublicKeyType
    
    func curve() -> WalletCore.Curve {
        switch publicKeyType {
        case .secp256k1:
            return .secp256k1
        case .nist256p1:
            return .nist256p1
        default:
            return .nist256p1
        }
    }
}
