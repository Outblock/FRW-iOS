//
//  SecureEnclave.swift
//  FRW
//
//  Created by cat on 2023/11/6.
//

import CryptoKit
import Foundation

// MARK: - SignError

enum SignError: Error, LocalizedError {
    case unknown
    case privateKeyEmpty
    case emptySignature

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        default:
            return"There was an error. Please try again."
        }
    }
}

// MARK: - WallectSecureEnclave

struct WallectSecureEnclave {
    // MARK: Lifecycle

    init(privateKey data: Data) {
        self.key = PrivateKey(data: data)
    }

    init() {
        self.key = PrivateKey()
    }

    // MARK: Internal

    let key: WallectSecureEnclave.PrivateKey

    func sign(data: Data) throws -> Data {
        guard let privateKey = key.privateKey else {
            throw SignError.privateKeyEmpty
        }
        do {
            let hashed = SHA256.hash(data: data)
            return try privateKey.signature(for: hashed).rawRepresentation
        } catch {
            debugPrint(error)
            throw error
        }
    }

    func sign(text: String) throws -> String? {
        guard let privateKey = key.privateKey else {
            throw SignError.privateKeyEmpty
        }
        guard let textData = text.data(using: .utf8) else {
            return nil
        }
        // TODO:
        let data = /* Flow.DomainTag.user.normalize + */ textData
        do {
            return try privateKey.signature(for: data).rawRepresentation.hexValue
        } catch {
            debugPrint(error)
            throw error
        }
    }
}
