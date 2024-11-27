//
//  SecureEnclaveMigration.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import CryptoKit
import FlowWalletKit
import Foundation
import KeychainAccess

// MARK: - SecureEnclaveMigration

enum SecureEnclaveMigration {
    // MARK: Internal

    static func start() {
        migrationFromOldSE()
        migrationFromLilicoTag()
    }

    // migrate from lilico tag,Caused by a misquote
    static func migrationFromLilicoTag() {
        let lilicoService = "io.outblock.lilico.securekey"
        let userKey = "user.keystore"
        let keychain = Keychain(service: lilicoService)
        guard let data = try? keychain.getData(userKey) else {
            log.info("[SecureEnclave] migration empty ")
            return
        }
        guard let users = try? JSONDecoder().decode([StoreInfo].self, from: data) else {
            log.info("[SecureEnclave] decoder failed on loginedUser ")
            return
        }
        for model in users {
            let se = try? SecureEnclaveKey.restore(
                secret: model.publicKey,
                storage: SecureEnclaveKey.KeychainStorage
            )
            try? se?.store(id: model.uniq)
        }
        log.debug("[Migration] total: \(users.count)")
    }

    static func canKeySign(privateKey: SecureEnclaveKey) -> Bool {
        guard let data = generateRandomBytes(),
              let _ = try? privateKey.sign(data: data, hashAlgo: .SHA2_256) else {
            return false
        }
        return true
    }

    // MARK: Private

    private static var service: String = "com.flowfoundation.wallet.securekey"
    private static var userKey: String = "user.keystore"

    private static func migrationFromOldSE() {
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
            if let privateKey = try? SecureEnclave.P256.Signing
                .PrivateKey(dataRepresentation: item.publicKey) {
                let secureKey = SecureEnclaveKey(
                    key: privateKey,
                    storage: SecureEnclaveKey.KeychainStorage
                )
                if canKeySign(privateKey: secureKey) {
                    try? secureKey.store(
                        id: item.uniq,
                        password: KeyProvider.password(with: item.uniq)
                    )
                    finishCount += 1
                }
            }
        }
        let endAt = CFAbsoluteTimeGetCurrent()
        log
            .debug(
                "[Migration] total: \(users.count), finish: \(finishCount), time:\(endAt - startAt)"
            )
    }

    private static func generateRandomBytes(length: Int = 32) -> Data? {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
        }

        if result == errSecSuccess {
            return keyData
        }

        return nil
    }
}

// MARK: - StoreInfo

private struct StoreInfo: Codable {
    // MARK: Lifecycle

    init(uniq: String, publicKey: Data) {
        self.uniq = uniq
        self.publicKey = publicKey
    }

    // MARK: Internal

    var uniq: String
    var publicKey: Data
}
