//
//  AccountKeyManager.swift
//  FRW
//
//  Created by cat on 2024/1/29.
//

import Flow
import Foundation

class AccountKeyManager {
    class func revokeKey(at index: Int) async throws -> Bool {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            HUD.info(title: "account_key_fail_tips".localized)
            throw LLError.invalidAddress
        }
        guard let data = try? JSONEncoder().encode(index) else {
            return false
        }
        guard index != WalletManager.shared.keyIndex else {
            return false
        }
        let flowId = try await FlowNetwork.revokeAccountKey(by: index, at: Flow.Address(hex: address))
        let holder = TransactionManager.TransactionHolder(id: flowId, type: .addToken, data: data)
        TransactionManager.shared.newTransaction(holder: holder)
        let result = try await flowId.onceSealed()
        if result.isFailed {
            log.error("[Flow] revoke failed. txid:\(flowId)")
            HUD.error(title: "account_key_fail_tips".localized)
            return false
        }
        return true
    }
}
