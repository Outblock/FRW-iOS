//
//  UrlProvider.swift
//  FRW
//
//  Created by Antonio Bello on 11/20/24.
//

import Foundation

enum AccountType {
    case flow, evm
    
    init(isEvm: Bool) {
        self = isEvm ? .evm : .flow
    }
    
    static var current: Self {
        return EVMAccountManager.shared.selectedAccount == nil ? .flow : .evm
    }
}

extension FlowNetworkType {
    func getTransactionHistoryUrl(accountType: AccountType, transactionId: String) -> URL? {
        let baseUrl = getHistoryBaseUrl(accountType: accountType)
        return URL(string: "\(baseUrl)/tx/\(transactionId)")
    }
    
    func getAccountUrl(accountType: AccountType, address: String) -> URL? {
        let baseUrl = getAccountBaseUrl(accountType: accountType)
        return URL(string: "\(baseUrl)/account/\(address)")
    }
    
    private func getHistoryBaseUrl(accountType: AccountType) -> String {
        return switch (accountType, self) {
        case (.evm, .testnet): "https://evm-testnet.flowscan.io"
        case (.evm, .mainnet): "https://evm.flowscan.io"
            
        case (.flow, .testnet): "https://testnet.flowscan.io"
        case (.flow, .mainnet): "https://www.flowscan.io"
        }
    }
    
    private func getAccountBaseUrl(accountType: AccountType) -> String {
        return switch (accountType, self) {
        case (_, .testnet): "https://testnet.flowscan.org"
        case (_, .mainnet): "https://flowscan.org"
        }
    }
}
