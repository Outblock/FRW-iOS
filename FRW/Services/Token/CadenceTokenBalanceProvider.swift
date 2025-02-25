//
//  EVMTokenBalanceHandler.swift
//  FRW
//
//  Created by Hao Fu on 22/2/2025.
//

import Foundation
import Flow
import Web3Core
import BigInt

class CadenceTokenBalanceProvider: TokenBalanceProvider {    
    var network: FlowNetworkType
    
    init(network: FlowNetworkType = LocalUserDefaults.shared.flowNetwork) {
        self.network = network
        
        // TODO: Add token list cache
    }
    
    func getFTBalance(address: Flow.Address) async throws -> [TokenModel] {
        let coinInfo: SingleTokenResponse = try await Network.requestWithRawModel(GithubEndpoint.ftTokenList(network))
        let models = coinInfo.tokens.map{ $0.toTokenModel(type: .cadence, network: network) }
        let balance = try await FlowNetwork.fetchBalance(at: address)
        
        var activeModels: [TokenModel] = []
        balance.keys.forEach { key in
            if let value = balance[key], value > 0  {
                if var model = models.first(where: { $0.contractId == key }) {
                    model.balance = Utilities.parseToBigUInt(String(format: "%f", balance[key] ?? 0), decimals: model.decimal) ?? BigUInt(0)
                    activeModels.append(model)
                }
            }
        }
        
        // Sort by balance
        let sorted = activeModels.sorted { lhs, rhs in
            guard let lBal = lhs.balance, let rBal = rhs.balance else {
                return true
            }
            return lBal > rBal
        }
        
        return sorted
    }
    
    func getNFTCollections(address: Flow.Address) async throws -> [NFTCollection] {
        let list: [NFTCollection] = try await Network.request(
            FRWAPI.NFT.userCollection(
                address.hexAddr,
                address.type
            )
        )
        let sorted = list.sorted(by: { $0.count > $1.count })
        return sorted
    }
    
    func getNFTCollectionDetail(address: EthereumAddress, collectionIdentifier: String, offset: Int) async throws -> NFTListResponse {
        let request = NFTCollectionDetailListRequest(
            address: address.address,
            collectionIdentifier: collectionIdentifier,
            offset: offset,
            limit: EVMTokenBalanceProvider.nftLimit
        )
        let response: NFTListResponse = try await Network.request(
            FRWAPI.NFT.collectionDetailList(
                request,
                address.type
            )
        )
        return response
    }
}
