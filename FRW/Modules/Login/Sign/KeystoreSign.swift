//
//  KeystoreSign.swift
//  FRW
//
//  Created by cat on 2024/8/22.
//

import CryptoKit
import Flow
import FlowWalletKit
import Foundation
import WalletCore

public struct KeyStoreHandler {
    // MARK: Public

    public func sign(data: Data) -> Data? {
        let hashedData = Hash.sha256(data: data)
        guard var signature = privateKey.sign(digest: hashedData, curve: curve) else {
            return nil
        }
        signature.removeLast()
        return signature
    }

    public func sign(text: String) -> String? {
        guard let textData = text.data(using: .utf8) else {
            return nil
        }
        return sign(data: textData)?.hexValue
    }

    // MARK: Internal

    let privateKey: WalletCore.PrivateKey
    let curve: WalletCore.Curve
}
