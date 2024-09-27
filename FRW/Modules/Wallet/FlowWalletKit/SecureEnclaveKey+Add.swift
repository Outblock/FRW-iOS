//
//  SecureEnclaveKey+Add.swift
//  FRW
//
//  Created by cat on 2024/9/10.
//

import Foundation
import FlowWalletKit
import Flow

extension SecureEnclaveKey {
    
    static func create() throws -> SecureEnclaveKey {
        
        let SecureEnclaveKey = try SecureEnclaveKey.create(storage: SecureEnclaveKey.KeychainStorage)
        return SecureEnclaveKey
    }
    
    static func wallet(id: String) throws -> SecureEnclaveKey {
        let pw = KeyProvider.password(with: id)
        let secureEnclaveKey = try SecureEnclaveKey.get(id: id, password: pw, storage: SecureEnclaveKey.KeychainStorage)
        return secureEnclaveKey
    }
    
    func flowAccountKey(signAlgo: Flow.SignatureAlgorithm = .ECDSA_P256 ,weight: Int = 1000) throws -> Flow.AccountKey {
        guard let publicData = try? publicKey() else {
            throw WalletError.emptyPublicKey
        }
        let key = Flow.AccountKey(publicKey: .init(data: publicData), signAlgo: signAlgo, hashAlgo: .SHA2_256, weight: weight)
        return key
    }
    
    func store(id: String ) throws {
        let pw = KeyProvider.password(with: id)
        try store(id: id, password: pw)
    }
}

//MARK: - Private
extension SecureEnclaveKey {
    static var KeychainStorage: FlowWalletKit.KeychainStorage {
        let service = (Bundle.main.bundleIdentifier ?? AppBundleName) + ".SE"
        let storage = FlowWalletKit.KeychainStorage(service: service, label: "SecureEnclaveKey", synchronizable: false)
        return storage
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
