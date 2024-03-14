//
//  OtherRequests.swift
//  Flow Wallet
//
//  Created by Selina on 26/9/2022.
//

import Foundation

struct SwapEstimateRequest: Codable {
    let inToken: String
    let outToken: String
    let inAmount: Double?
    let outAmount: Double?
}
