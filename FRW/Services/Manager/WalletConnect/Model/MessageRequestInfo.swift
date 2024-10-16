//
//  MessageRequestInfo.swift
//  Flow Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation
import WalletConnectSign

struct RequestMessageInfo {
    let name: String
    let descriptionText: String
    let dappURL: String
    let iconURL: String
    let chains: Set<Blockchain>?
    let methods: Set<String>?
    let pendingRequests: [String]
    let message: String
}
