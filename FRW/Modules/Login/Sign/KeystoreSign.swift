//
//  KeystoreSign.swift
//  FRW
//
//  Created by cat on 2024/8/22.
//

import Foundation
import WalletCore
import CryptoKit
import FlowWalletCore
import Flow

public struct KeyStoreHandler {
    
    let privateKey: WalletCore.PrivateKey
    let curve: WalletCore.Curve
    
    
    public func sign(data: Data) -> Data? {
        let hashedData = Hash.sha256(data: data)
        guard var signature = privateKey.sign(digest: hashedData, curve: curve) else {
            return nil
        }
        signature.removeLast()
        return signature
    }

    public func sign(text: String)  -> String? {
        guard let textData = text.data(using: .utf8) else {
            return nil
        }
        return sign(data: textData)?.hexValue
    }
}
