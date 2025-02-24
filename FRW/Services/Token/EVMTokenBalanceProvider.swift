//
//  EVMTokenBalanceHandler.swift
//  FRW
//
//  Created by Hao Fu on 22/2/2025.
//

import Foundation
import Web3Core

class EVMTokenBalanceProvider: TokenBalanceProvider {
    var network: FlowNetworkType
    
    init(network: FlowNetworkType = LocalUserDefaults.shared.flowNetwork) {
        self.network = network
    }
    
    func getFTBalance(address: EthereumAddress) async throws -> [TokenModel] {
        guard let web3 = try await FlowProvider.Web3.default(networkType: network) else {
            throw EVMError.rpcError
        }
        
        let flowBalance = try await web3.eth.getBalance(for: address)
        let response: [EVMTokenResponse] = try await Network.request(FRWAPI.EVM.tokenList(address.address))
        var models = response.map{ $0.toTokenModel(type: .evm) }
        var flowModel = TokenBalanceHandler.flowToken.toTokenModel(type: TokenModel.TokenType.evm, network: network)
        flowModel.balance = flowBalance
        models.insert(flowModel, at: 0)
        
        // Sort by balance
        let sorted = models.sorted { lhs, rhs in
            guard let lBal = lhs.readableBalance, let rBal = rhs.readableBalance else {
                return false
            }
            return lBal > rBal
        }
        
        return models
    }
    
    func getNFTCollections(address: EthereumAddress) async throws -> [NFTCollectionInfo] {
        // TODO: Add NFT Fetch
        return []
    }
    
    func getNFTCollectionList(address: EthereumAddress) async throws -> [NFTCollectionInfo] {
        // TODO: Add NFT Fetch
        return []
    }
}
