//
//  PhraseKeyStore.swift
//  FRW
//
//  Created by cat on 2024/9/19.
//

import Foundation
import KeychainAccess

struct PhraseKeyStore {
    private static let defaultBundleID = "com.flowfoundation.wallet"
    private var mainKeychain = Keychain(service: (Bundle.main.bundleIdentifier ?? defaultBundleID) + ".backup.phrase")
        .label("Lilico app backup")
        .synchronizable(false)
        .accessibility(.whenUnlocked)
    
    func addMnemonic(mnemonic: String, userId: String) throws {
        guard var data = mnemonic.data(using: .utf8) else {
            throw WalletError.storeAndActiveMnemonicFailed
        }
        
        defer {
            data = Data()
        }
        
        var encodedData = try WalletManager.encryptionChaChaPoly(key: userId, data: data)
        defer {
            encodedData = Data()
        }
        
        if let existingMnemonic = getMnemonicFromKeychain(uid: userId) {
            if existingMnemonic != mnemonic {
                log.error("existingMnemonic should equal the current")
                throw WalletError.existingMnemonicMismatch
            }
        } else {
            try mainKeychain.comment("Flow User Id:\(userId)").set(encodedData, key: userId)
        }
    }
    
    func getMnemonicFromKeychain(uid: String) -> String? {
        
        if var encryptedData = try? mainKeychain.getData(uid),
           var decryptedData = try? WalletManager.decryptionChaChaPoly(key: uid, data: encryptedData),
           var mnemonic = String(data: decryptedData, encoding: .utf8)
        {
            defer {
                encryptedData = Data()
                decryptedData = Data()
                mnemonic = ""
            }

            return mnemonic
        }
        
        return nil
    }
}