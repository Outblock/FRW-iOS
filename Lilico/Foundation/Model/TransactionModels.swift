//
//  TransactionModels.swift
//  Lilico
//
//  Created by Selina on 29/8/2022.
//

import Foundation

struct CoinTransferModel: Codable {
    var amount: Double
    var symbol: String
    var target: Contact
    var from: String
}

struct NFTTransferModel: Codable {
    var nft: NFTModel
    var target: Contact
    var from: String
}
