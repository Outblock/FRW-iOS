//
//  WallectSecureEnclavePrivateKey.swift
//  FRW
//
//  Created by cat on 2023/11/7.
//

import CryptoKit
import Foundation

extension WallectSecureEnclave {
    struct PrivateKey {
        // MARK: Lifecycle

        init(data: Data) {
            do {
                self.privateKey = try SecureEnclave.P256.Signing
                    .PrivateKey(dataRepresentation: data)
            } catch {
                debugPrint("[WallectSecureEnclave] init with data failed.")
            }
        }

        init() {
            do {
                self.privateKey = try PrivateKey.generate()
            } catch {
                debugPrint("[WallectSecureEnclave] init failed.")
            }
        }

        // MARK: Internal

        var privateKey: SecureEnclave.P256.Signing.PrivateKey?

        var publicKey: P256.Signing.PublicKey? {
            privateKey?.publicKey
        }

        var publickeyValue: String? {
            publicKey?.rawRepresentation.hexValue
        }

        static func generate() throws -> SecureEnclave.P256.Signing.PrivateKey {
            try SecureEnclave.P256.Signing.PrivateKey()
        }
    }
}
