//
//  BackupEncryption.swift
//  Dapper
//
//  Created by Hao Fu on 7/10/2022.
//

import Foundation
import CryptoKit

protocol SymmetricEncryption {
    var key: SymmetricKey { get }
    var keySize: SymmetricKeySize { get }
    func encrypt(data: Data) throws -> Data
    func decrypt(combinedData: Data) throws -> Data
}

enum EncryptionError: Swift.Error {
    case encryptFailed
    case initFailed
}

class ChaChaPolyCipher: SymmetricEncryption {
    var key: SymmetricKey
    var keySize: SymmetricKeySize = .bits256
    
    func encrypt(data: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.seal(data, using: key)
        return sealedBox.combined
    }
    
    func decrypt(combinedData: Data) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: combinedData)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        return decryptedData
    }
    
    init?(key: String) {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        let hashedKey = SHA256.hash(data: keyData)
        let bitKey = Data(hashedKey.prefix(keySize.bitCount))
        self.key = SymmetricKey(data: bitKey)
    }
}


class AESGCMCipher: SymmetricEncryption {
    var key: SymmetricKey
    var keySize: SymmetricKeySize = .bits256
    
    func encrypt(data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let encryptedData = sealedBox.combined else {
            throw EncryptionError.encryptFailed
        }
        return encryptedData
    }
    
    func decrypt(combinedData: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        return decryptedData
    }
    
    init?(key: String) {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        let hashedKey = SHA256.hash(data: keyData)
        let bitKey = Data(hashedKey.prefix(keySize.bitCount))
        self.key = SymmetricKey(data: bitKey)
    }
}
