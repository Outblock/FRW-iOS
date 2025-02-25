//
//  TokenBalanceProvider.swift
//  FRW
//
//  Created by Hao Fu on 25/2/2025.
//

import Foundation

protocol TokenBalanceProvider {
    var network: FlowNetworkType { get }
    func getFTBalance(address: FWAddress) async throws -> [TokenModel]
    func getFTBalanceWithId(address: FWAddress, tokenId: String) async throws -> TokenModel?
    func getNFTCollections(address: FWAddress) async throws -> [NFTCollection]
    func getNFTCollectionDetail(address: FWAddress, collectionIdentifier: String, offset: Int) async throws -> NFTListResponse
}

extension TokenBalanceProvider {
    func getFTBalanceWithId(address: FWAddress, tokenId: String) async throws -> TokenModel? {
        let models = try await getFTBalance(address: address)
        return models.first{ $0.id == tokenId }
    }
}
