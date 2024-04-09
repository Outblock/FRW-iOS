//
//  CadenceTemplate+AccountKeys.swift
//  FRW
//
//  Created by cat on 2023/10/20.
//

import Foundation

extension CadenceTemplate {
    static let revokeAccountKey = """
    transaction(keyIndex: Int) {
        prepare(signer: AuthAccount) {
            // Get a key from an auth account.
            let keyA = signer.keys.revoke(keyIndex: keyIndex)
        }
    }
    """
    
    static let addKeyToAccount = """
        import Crypto
        transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64) {
            prepare(signer: AuthAccount) {
                let key = PublicKey(
                    publicKey: publicKey.decodeHex(),
                    signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
                )
                signer.keys.add(
                    publicKey: key,
                    hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
                    weight: weight
                )
            }
        }
    """
    
}
