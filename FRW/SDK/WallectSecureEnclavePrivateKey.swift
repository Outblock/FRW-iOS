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
        var privateKey: SecureEnclave.P256.Signing.PrivateKey?

        var publicKey: P256.Signing.PublicKey? {
            return privateKey?.publicKey
        }

        var publickeyValue: String? {
            return publicKey?.rawRepresentation.hexValue
        }

        init(data: Data) {
            do {
                privateKey = try SecureEnclave.P256.Signing.PrivateKey(dataRepresentation: data)
            } catch {
                debugPrint("[WallectSecureEnclave] init with data failed.")
            }
        }

        init() {
            do {
                privateKey = try PrivateKey.generate()
            } catch {
                debugPrint("[WallectSecureEnclave] init failed.")
            }
        }

        static func generate() throws -> SecureEnclave.P256.Signing.PrivateKey {
            return try SecureEnclave.P256.Signing.PrivateKey()
        }
    }
}
