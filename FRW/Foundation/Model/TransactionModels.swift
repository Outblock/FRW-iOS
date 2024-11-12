//
//  TransactionModels.swift
//  Flow Wallet
//
//  Created by Selina on 29/8/2022.
//

import Foundation

// MARK: - CoinTransferModel

struct CoinTransferModel: Codable {
    var amount: Double
    var symbol: String
    var target: Contact
    var from: String
}

// MARK: - NFTTransferModel

struct NFTTransferModel: Codable {
    var nft: NFTModel
    var target: Contact
    var from: String
}
