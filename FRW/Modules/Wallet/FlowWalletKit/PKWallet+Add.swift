//
//  File.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Foundation
import FlowWalletKit
import Flow

extension FlowWalletKit.PrivateKey {
    
    
    func store(id: String ) throws {
        let pw = PrivateKey.password(by: id)
        try store(id: id, password: pw)
    }
}

extension FlowWalletKit.PrivateKey {
    
    static var PKStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + ".PK"
        let storage = FlowWalletKit.KeychainStorage(service: service, label: "PKWallet", synchronizable: false)
        return storage
    }
    
    static func password(by id: String) -> String {
        let aseKey = LocalEnvManager.shared.backupAESKey
        return aseKey
    }
}
