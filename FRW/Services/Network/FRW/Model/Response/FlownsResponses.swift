//
//  FlownsResponses.swift
//  Flow Reference Wallet
//
//  Created by Selina on 16/9/2022.
//

import Foundation

struct ClaimDomainPrepareResponse: Codable {
    let cadence: String?
    let domain: String?
    let flownsServerAddress: String?
    let lilicoServerAddress: String?
}

struct ClaimDomainSignatureResponse: Codable {
    let txId: String?
}

// MARK: - Inbox

struct InboxResponse: Codable {
    let id: String
    let owner: String
    let name: String
    let vaultBalances: [String: String]
    let collections: [String: [String]]
    
    var tokenList: [InboxToken] {
        return vaultBalances.map { item in
            let dataArray = item.key.components(separatedBy: ["."])
            return InboxToken(key: item.key, coinAddress: dataArray[1].addHexPrefix(), coinSymbol: dataArray[2], amount: Double(item.value) ?? 0)
        }.filter { $0.amount != 0 }
    }
    
    var nftList: [InboxNFT] {
        return collections.map { item in
            let dataArray = item.key.components(separatedBy: ["."])
            
            return item.value.map { string in
                return InboxNFT(key: item.key, collectionAddress: dataArray[1].addHexPrefix(), collectionName: dataArray[2], tokenId: string)
            }
        }.flatMap { $0 }
    }
}

struct InboxToken: Codable {
    let key: String
    let coinAddress: String
    let coinSymbol: String
    let amount: Double
    
    var iconURL: URL? {
        return matchedCoin?.icon
    }
    
    var amountText: String {
        return "\(amount.formatCurrencyString()) \(matchedCoin?.symbol?.uppercased() ?? "")"
    }
    
    var marketPrice: Double {
        guard let coin = matchedCoin, let rate = CoinRateCache.cache.getSummary(for: coin.symbol ?? "") else {
            return 0
        }
        
        return rate.getLastRate() * amount
    }
    
    var matchedCoin: TokenModel? {
        guard let coins = WalletManager.shared.supportedCoins else {
            return nil
        }
        
        for coin in coins {
            if let addr = coin.getAddress(), addr == coinAddress {
                return coin
            }
        }
        
        return nil
    }
}

struct InboxNFT: Codable {
    let key: String
    let collectionAddress: String
    let collectionName: String
    let tokenId: String
    
    var localCollection: NFTCollectionInfo? {
        return NFTCollectionConfig.share.config.first { $0.address == collectionAddress }
    }
}
