//
//  AccountRequests.swift
//  Flow Wallet
//
//  Created by Selina on 14/9/2022.
//

import Foundation

// MARK: - TransfersRequest

struct TransfersRequest: Codable {
    let address: String
    let limit: Int
    let after: String
}

// MARK: - TokenTransfersRequest

struct TokenTransfersRequest: Codable {
    let address: String
    let limit: Int
    let after: String
    let token: String
}
