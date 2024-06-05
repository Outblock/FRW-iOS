//
//  EVMModels.swift
//  FRW
//
//  Created by cat on 2024/4/24.
//

import Foundation
import web3swift
import Web3Core
import BigInt

struct EVMTransactionExecuted: Codable {
    let hash: String?
    let blockHash: String?    
}

struct EVMTransactionReceive: Codable {
    let to: String?
    let from: String?
    let value: String?
    let gas: String?
    let data: String?
    
    var amount: String {
        let defaultValue = "0"
        guard let balance = value else { return defaultValue }
        guard let value = BigUInt(from: balance) else { return defaultValue }
        return Utilities.formatToPrecision(value)
    }
    
    var gasValue: UInt64 {
        let defaultValue: UInt64 = WalletManager.defaultGas
        guard let gasStr = gas else { return defaultValue }
        guard let value = UInt64(gasStr.stripHexPrefix(), radix: 16) else { return defaultValue }
        return value
    }
    
    var dataValue: Data? {
        guard let dataStr = data else { return nil }
        guard let value = BigUInt(from: dataStr) else { return nil }
        return Data(from: value.hexString)
    }
    
    var toAddress: String? {
        return to?.stripHexPrefix()
    }
}
