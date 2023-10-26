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
}
