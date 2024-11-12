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
    static func wallet(id: String) throws -> FlowWalletKit.PrivateKey {
        let pw = KeyProvider.password(with: id)
        let privateKey = try FlowWalletKit.PrivateKey.get(
            id: id,
            password: pw,
            storage: PrivateKey.PKStorage
        )
        return privateKey
    }

    func store(id: String) throws {
        let pw = KeyProvider.password(with: id)
        try store(id: id, password: pw)
    }
}

extension FlowWalletKit.PrivateKey {
    static var PKStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + ".PK"
        let storage = FlowWalletKit.KeychainStorage(
            service: service,
            label: "PKWallet",
            synchronizable: false
        )
        return storage
    }
}
