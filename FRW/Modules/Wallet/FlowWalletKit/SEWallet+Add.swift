//
//  SEWallet+Add.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Foundation
import FlowWalletKit
import Flow

extension SEWallet {
    
    static func create() throws -> SEWallet {
        
        let SEWallet = try SEWallet.create(storage: SEWallet.KeychainStorage)
        return SEWallet
    }
    
    static func wallet(id: String) throws -> SEWallet {
        let pw = password(by: id)
        let SEWallet = try SEWallet.get(id: id, password: pw, storage: SEWallet.KeychainStorage)
        return SEWallet
    }
    
    func flowAccountKey(signAlgo: Flow.SignatureAlgorithm = .ECDSA_P256 ,weight: Int = 1000) throws -> Flow.AccountKey {
        guard let publicData = try? publicKey() else {
            throw WalletError.emptyPublicKey
        }
        let key = Flow.AccountKey(publicKey: .init(data: publicData), signAlgo: signAlgo, hashAlgo: .SHA2_256, weight: weight)
        return key
    }
    
    func store(id: String ) throws {
        let pw = SEWallet.password(by: id)
        try store(id: id, password: pw)
    }
}

//MARK: - Private
extension SEWallet {
    static var KeychainStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + ".SE"
        let storage = FlowWalletKit.KeychainStorage(service: service, label: "SEWallet")
        return storage
    }
    
    static func password(by id: String) -> String {
        let aseKey = LocalEnvManager.shared.backupAESKey
        return aseKey
    }
}

//MARK: - String
extension String {
    func addUserMessage() -> Data? {
        guard let textData = self.data(using: .utf8) else {
            return nil
        }
        return Flow.DomainTag.user.normalize + textData
    }
}

extension Data {
    public func signUserMessage() -> Data {
        return Flow.DomainTag.user.normalize + self
    }
}
