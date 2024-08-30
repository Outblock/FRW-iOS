//
//  NFTCollectionModel.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/22.
//

import Foundation
import Flow


final class NFTCollectionConfig {
    static let share = NFTCollectionConfig()
    private init() {}

    var config: [NFTCollectionInfo] = []

    func reload() async {
        await fetchData()
    }

    func get(from address: String) async -> NFTCollectionInfo? {
        if config.isEmpty {
            await fetchData()
        }
        return config.first { $0.address == address }
    }
}

extension NFTCollectionConfig {
    private func fetchData() async {
        do {
            
            var list: [NFTCollectionInfo]
            //TODO: check
            // CadenceManager.shared.isGreaterVerson1() && EVMAccountManager.shared.selectedAccount != nil
            if LocalUserDefaults.shared.flowNetwork == .previewnet {
                let response: EVMNFTCollectionResponse = try await Network.requestWithRawModel(GithubEndpoint.EVMNFTList)
                list = response.tokens
            }else {
                list = try await Network.request(FRWAPI.NFT.collections)
            }
            config = list
        } catch {
            debugPrint("NFTCollectionConfig -> fetchData failed: \(error)")
        }
    }
}
