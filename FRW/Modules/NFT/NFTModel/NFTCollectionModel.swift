//
//  NFTCollectionModel.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/22.
//

import Flow
import Foundation

// MARK: - NFTCollectionConfig

final class NFTCollectionConfig {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let share = NFTCollectionConfig()

    var config: [NFTCollectionInfo] = []

    func reload() async {
        await fetchData()
    }

    func get(from address: String) async -> NFTCollectionInfo? {
        if config.isEmpty {
            await fetchData()
        }
        return config.first { $0.address?.lowercased() == address.lowercased() }
    }
}

extension NFTCollectionConfig {
    private func fetchData() async {
        do {
            let list: [NFTCollectionInfo] = try await Network.request(
                FRWAPI.NFT.collections
            )
            config = list
        } catch {
            log.error("NFTCollectionConfig -> fetchData failed: \(error)")
        }
    }
}
