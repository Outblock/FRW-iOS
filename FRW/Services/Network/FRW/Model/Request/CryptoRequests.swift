//
//  CryptoRequests.swift
//  Flow Wallet
//
//  Created by Selina on 23/6/2022.
//

import Foundation

struct CryptoSummaryRequest: Codable {
    let provider: String
    let pair: String
}

struct CryptoHistoryRequest: Codable {
    let provider: String
    let pair: String
    let after: String
    let period: String
}
