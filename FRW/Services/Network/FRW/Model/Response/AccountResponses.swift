//
//  AccountResponses.swift
//  Flow Reference Wallet
//
//  Created by Selina on 9/9/2022.
//

import Foundation

extension FlowScanAccountTransferCountResponse {
    struct Data: Codable {
        let account: FlowScanAccountTransferCountResponse.Account?
    }
    
    struct Account: Codable {
        let transactionCount: Int?
    }
}

struct FlowScanAccountTransferCountResponse: Codable {
    let data: FlowScanAccountTransferCountResponse.Data?
}


struct FlowTransferCountResponse: Codable {
    let data: FlowTransferCountResponse.Data?
}

extension FlowTransferCountResponse {
    struct Data: Codable {
        let participationsAggregate: FlowTransferCountResponse.Participation?
    }
    
    struct Participation: Codable {
        let aggregate: Aggregate?
    }
    struct Aggregate: Codable {
        let count: Int
    }
}

// MARK: -

extension FlowScanTokenTransferResponse {
    struct Data: Codable {
        let account: FlowScanTokenTransferResponse.Account?
    }
    
    struct Account: Codable {
        let tokenTransfers: FlowScanTokenTransferResponse.TokenTransfers?
    }
    
    struct TokenTransfers: Codable {
        let edges: [FlowScanTokenTransferResponse.Edge?]?
        let pageInfo: FlowScanTokenTransferResponse.PageInfo?
    }
    
    struct Edge: Codable {
        let node: FlowScanTokenTransferResponse.Node?
    }
    
    struct Node: Codable {
        let amount: FlowScanTokenTransferResponse.Amount?
        let counterpartiesCount: Int?
        let counterparty: FlowScanTokenTransferResponse.Counterparty?
        let transaction: FlowScanTransaction?
        let type: String?
    }
    
    struct PageInfo: Codable {
        let endCursor: String?
        let hasNextPage: Bool?
    }
    
    struct Amount: Codable {
        let token: FlowScanTokenTransferResponse.Token?
        let value: String?
    }
    
    struct Counterparty: Codable {
        let address: String?
    }
    
    struct Token: Codable {
        let id: String?
    }
}

struct FlowScanTokenTransferResponse: Codable {
    let data: FlowScanTokenTransferResponse.Data?
}

// MARK: - 

extension FlowScanAccountTransferResponse {
    struct Data: Codable {
        let account: FlowScanAccountTransferResponse.Account?
    }
    
    struct Transactions: Codable {
        let edges: [Edge?]?
    }
    
    struct Edge: Codable {
        let node: FlowScanTransaction?
    }
    
    struct Account: Codable {
        let transactionCount: Int?
        let transactions: FlowScanAccountTransferResponse.Transactions?
    }
}

struct FlowScanAccountTransferResponse: Codable {
    let data: FlowScanAccountTransferResponse.Data?
}

// MARK: -

struct TransfersResponse: Codable {
    let next: Bool?
    let string: String?
    let total: Int?
    let transactions: [FlowScanTransfer]?
}
