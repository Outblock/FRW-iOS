//
//  PKWallet+Add.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Flow
import FlowWalletKit
import Foundation

extension FlowWalletKit.PrivateKey {
    private static let suffix = ".PK"
    static func wallet(id: String) throws -> FlowWalletKit.PrivateKey {
        let pw = KeyProvider.password(with: id)
        let key = KeyProvider.lastKey(with: id, in: PKStorage) ?? id
        let privateKey = try FlowWalletKit.PrivateKey.get(
            id: key,
            password: pw,
            storage: PrivateKey.PKStorage
        )
        return privateKey
    }

    func store(id: String) throws {
        let pw = KeyProvider.password(with: id)
        let key = self.createKey(uid: id)
        try store(id: key, password: pw)
    }
}

extension FlowWalletKit.PrivateKey {
    static var PKStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + FlowWalletKit.PrivateKey
            .suffix
        let storage = FlowWalletKit.KeychainStorage(
            service: service,
            label: "PKWallet",
            synchronizable: false
        )
        return storage
    }
}
