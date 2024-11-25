//
//  SignedRequest.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import Foundation

// MARK: - SignedRequest

struct SignedRequest: Codable {
    let accountKey: AccountKey
    let signatures: [AccountKeySignature]
}

// MARK: - AccountKeySignature

struct AccountKeySignature: Codable {
    // MARK: Lifecycle

    init(
        hashAlgo: Int,
        publicKey: String,
        signAlgo: Int,
        signMessage: String?,
        signature: String,
        weight: Int
    ) {
        self.hashAlgo = hashAlgo
        self.publicKey = publicKey
        self.signAlgo = signAlgo
        self.signMessage = signMessage
        self.signature = signature
        self.weight = weight
    }

    // MARK: Internal

    let hashAlgo: Int
    let publicKey: String
    let signAlgo: Int
    let signMessage: String?
    let signature: String
    var weight: Int = 1000
}
