//
//  StakingInfo.swift
//  Flow Reference Wallet
//
//  Created by Selina on 1/12/2022.
//

import Foundation

struct StakingNode: Codable {
    let id: Int
    let nodeID: String
    let tokensCommitted: Double
    let tokensStaked: Double
    let tokensUnstaking: Double
    let tokensRewarded: Double
    let tokensUnstaked: Double
    let tokensRequestedToUnstake: Double
    
    var stakingCount: Double {
        return tokensCommitted + tokensStaked
    }
    
    var isLilico: Bool {
        return StakingProviderCache.cache.providers.first { $0.isLilico }?.id == nodeID
    }
    
    var tokenStakedASUSD: Double {
        let rate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0.0
        return tokensStaked * rate
    }
    
    var dayRewards: Double {
        let apy = isLilico ? StakingManager.shared.apy : StakingDefaultNormalApy
        return stakingCount * apy / 365.0
    }
    
    var monthRewards: Double {
        return dayRewards * 30
    }
    
    var dayRewardsASUSD: Double {
        let coinRate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return dayRewards * coinRate
    }
    
    var monthRewardsASUSD: Double {
        let coinRate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return monthRewards * coinRate
    }
}

// MARK: - DelegatorInner

struct StakingDelegatorInner: Codable {
    let type: String?
    let value: StakingDelegatorInner.Value1?
}

extension StakingDelegatorInner {
    struct Value1: Codable {
        let type: String?
        let value: [StakingDelegatorInner.Value1.Value2?]?
    }
}

extension StakingDelegatorInner.Value1 {
    struct Value2: Codable {
        let key: StakingDelegatorInner.Value1.Value2.Key?
        let value: StakingDelegatorInner.Value1.Value2.Value?
    }
}

extension StakingDelegatorInner.Value1.Value2 {
    struct Key: Codable {
        let type: String?
        let value: String?
    }
    
    struct Value: Codable {
        let type: String?
        let value: [StakingDelegatorInner.Value1.Value2.Value.Value3?]?
    }
}

extension StakingDelegatorInner.Value1.Value2.Value {
    struct Value3: Codable {
        let key: StakingDelegatorInner.Value1.Value2.Value.Value3.Key?
    }
}

extension StakingDelegatorInner.Value1.Value2.Value.Value3 {
    struct Key: Codable {
        let type: String?
        let value: String?
    }
}
