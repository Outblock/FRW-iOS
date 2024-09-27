//
//  SecureEnclaveMigration.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Foundation
import KeychainAccess
import FlowWalletKit
import CryptoKit

struct SecureEnclaveMigration {
    private static var service: String = "com.flowfoundation.wallet.securekey"
    private static var userKey: String = "user.keystore"
    
    static func start() {
        let keychain = Keychain(service: service)
        guard let data = try? keychain.getData(userKey) else {
            print("[Migration] SecureEnclave get value from keychain empty,\(service)")
            return
        }
        guard let users = try? JSONDecoder().decode([StoreInfo].self, from: data) else {
            print("[Migration] SecureEnclave list decoder failed ")
            return
        }
        let startAt = CFAbsoluteTimeGetCurrent()
        var finishCount = 0
        for item in users {
            if let privateKey = try? SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: item.publicKey) {
                let secureKey = SecureEnclaveKey(key: privateKey, storage: SecureEnclaveKey.KeychainStorage)
                try? secureKey.store(id: item.uniq, password: KeyProvider.password(with: item.uniq))
                finishCount += 1
            }
        }
        let endAt = CFAbsoluteTimeGetCurrent()
        log.debug("[Migration] total: \(users.count), finish: \(finishCount), time:\((endAt - startAt))")
        
    }
}

private struct StoreInfo: Codable {
    var uniq: String
    var publicKey: Data
    
    init(uniq: String, publicKey: Data) {
        self.uniq = uniq
        self.publicKey = publicKey
    }
}
