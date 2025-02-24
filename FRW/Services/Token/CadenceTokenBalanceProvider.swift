//
//  EVMTokenBalanceHandler.swift
//  FRW
//
//  Created by Hao Fu on 22/2/2025.
//

import Foundation
import Flow
import Web3Core

class CadenceTokenBalanceProvider: TokenBalanceProvider {
    var network: FlowNetworkType
    
    init(network: FlowNetworkType = LocalUserDefaults.shared.flowNetwork) {
        self.network = network
    }
    
    func getFTBalance(address: Flow.Address) async throws -> [TokenModel] {
        let coinInfo: SingleTokenResponse = try await Network.requestWithRawModel(GithubEndpoint.ftTokenList(network))
        let models = coinInfo.tokens.map{ $0.toTokenModel(type: .cadence, network: network) }
        let balance = try await FlowNetwork.fetchBalance(at: address)
        
        var activeModels: [TokenModel] = []
        balance.keys.forEach { key in
            if let value = balance[key], value > 0  {
                if var model = models.first(where: { $0.contractId == key }) {
                    model.balance = Utilities.parseToBigUInt(String(balance[key] ?? 0), decimals: model.decimal)
                    activeModels.append(model)
                }
            }
        }
        
        return activeModels
    }
    
    func getNFTCollections(address: Flow.Address) async throws -> [NFTCollectionInfo] {
        // TODO: Add NFT Fetch
        return []
    }
    
    func getNFTCollectionList(address: Flow.Address) async throws -> [NFTCollectionInfo] {
        // TODO: Add NFT Fetch
        return []
    }
}
