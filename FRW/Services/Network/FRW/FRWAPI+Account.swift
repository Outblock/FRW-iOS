//
//  Flow WalletAPI+Account.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import Foundation
import Moya

extension FRWAPI {
    enum Account {
        case flowScanQuery(String)
        case transfers(TransfersRequest)
        case tokenTransfers(TokenTransfersRequest)
    }
}

extension FRWAPI.Account: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        return Config.get(.lilico)
    }
    
    var path: String {
        switch self {
        case .flowScanQuery:
            return "/v2/account/query"
        case .transfers:
            return "/v1/account/transfers"
        case .tokenTransfers:
            return "/v1/account/tokentransfers"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .flowScanQuery:
            return .get
        case .transfers, .tokenTransfers:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .flowScanQuery(let query):
            return .requestParameters(parameters: ["address": query], encoding: URLEncoding.queryString)
        case .transfers(let request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding.queryString)
        case .tokenTransfers(let request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return FRWAPI.commonHeaders
    }
}

extension FRWAPI.Account {
    static func fetchAccountTransferCount() async throws -> Int {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return 0
        }
        
        let response: FlowTransferCountResponse = try await Network.request(FRWAPI.Account.flowScanQuery(address))
        return response.data?.participationsAggregate?.aggregate?.count ?? 0
    }
    
    static func fetchAccountTransfers() async throws -> ([FlowScanTransaction], Int) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return ([], 0)
        }
        
        let script = """
           query AccountTransfers {
               account(id: "\(address)") {
               transactions (
                   first: 30
                   ordering: Descending
               ) {
                   edges {
                       node {
                           error
                           hash
                           status
                           eventCount
                           time
                           index
                           payer {
                               address
                           }
                           proposer {
                               address
                           }
                           authorizers {
                               address
                           }
                           contractInteractions {
                               identifier
                           }
                       }
                   }
               }
               transactionCount
               }
           }
        """
        
        let response: FlowScanAccountTransferResponse = try await Network.request(FRWAPI.Account.flowScanQuery(script))
        
        guard let edges = response.data?.account?.transactions?.edges else {
            return ([], 0)
        }
        
        var results = [FlowScanTransaction]()
        for edge in edges {
            if let transaction = edge?.node, transaction.hash != nil, transaction.time != nil {
                results.append(transaction)
            }
        }
        
        return (results, response.data?.account?.transactionCount ?? results.count)
    }
    
    static func fetchTokenTransfers(contractId: String) async throws -> [FlowScanTransaction] {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return []
        }
        
        let script = """
           query AccountTransfers {
                account(id: "\(address)") {
                    tokenTransfers (
                        first: 30
                        ordering: Descending
                        contractId: "\(contractId)"
                    ) {
                        pageInfo {
                            hasNextPage
                            endCursor
                        }
                        edges {
                            node {
                                transaction {
                                   error
                                   hash
                                   status
                                   eventCount
                                   time
                                   index
                                   payer {
                                       address
                                   }
                                   proposer {
                                       address
                                   }
                                   authorizers {
                                       address
                                   }
                                   contractInteractions {
                                       identifier
                                   }
                                }
                                type
                                amount {
                                    token {
                                        id
                                    }
                                    value
                                }
                                counterparty {
                                    address
                                }
                                counterpartiesCount
                            }
                        }
                    }
                }
            }
        """
        
        let response: FlowScanTokenTransferResponse = try await Network.request(FRWAPI.Account.flowScanQuery(script))
        
        guard let edges = response.data?.account?.tokenTransfers?.edges else {
            return []
        }
        
        var results = [FlowScanTransaction]()
        for edge in edges {
            if let transaction = edge?.node?.transaction, transaction.hash != nil, transaction.time != nil {
                results.append(transaction)
            }
        }
        
        return results
    }
}
