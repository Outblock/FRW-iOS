//
//  StakingDetailViewModel.swift
//  Flow Reference Wallet
//
//  Created by Selina on 13/12/2022.
//

import SwiftUI
import Combine

class StakingDetailViewModel: ObservableObject {
    @Published var provider: StakingProvider
    @Published var node: StakingNode
    
    private var cancelSets = Set<AnyCancellable>()
    
    init(provider: StakingProvider, node: StakingNode) {
        self.provider = provider
        self.node = node
        
        StakingManager.shared.$nodeInfos.sink { [weak self] nodes in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                if let newNode = nodes.first(where: { $0.id == self.node.id && $0.nodeID == self.node.nodeID }) {
                    self.node = newNode
                }
            }
        }.store(in: &cancelSets)
    }
    
    var availableAmount: Double {
        let balance = WalletManager.shared.getBalance(bySymbol: "flow")
        return balance
    }
    
    var currentProgress: Int {
        let startDate = StakingManager.shared.stakingEpochStartTime
        let now = Date()
        if startDate > now {
            return 0
        }
        
        let daySeconds = Double(24 * 60 * 60)
        let progressIndex = Int((now.timeIntervalSince1970 - startDate.timeIntervalSince1970) / daySeconds) + 1
        return min(progressIndex, 7)
    }
    
    func stakeAction() {
        Router.route(to: RouteMap.Wallet.stakeAmount(provider, isUnstake: false))
    }
    
    func claimStake() {
        guard let delegatorId = provider.delegatorId else {
            return
        }
        
        if node.tokensRewarded.decimalValue <= 0 {
            HUD.error(title: "stake_insufficient_balance".localized)
            return
        }
        
        Task {
            do {
                HUD.loading("staking_claim_rewards".localized)
                let _ = try await StakingManager.shared.claimReward(nodeID: node.nodeID, delegatorId: delegatorId, amount: node.tokensRewarded.decimalValue)
                HUD.dismissLoading()
            } catch {
                debugPrint(error)
                HUD.dismissLoading()
                HUD.error(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func restake() {
        guard let delegatorId = provider.delegatorId else {
            return
        }
        
        if node.tokensRewarded.decimalValue <= 0 {
            HUD.error(title: "stake_insufficient_balance".localized)
            return
        }
        
        Task {
            do {
                HUD.loading("staking_reStake_rewards".localized)
                let _ = try await StakingManager.shared.reStakeReward(nodeID: node.nodeID, delegatorId: delegatorId, amount: node.tokensRewarded.decimalValue)
                HUD.dismissLoading()
            } catch {
                debugPrint(error)
                HUD.dismissLoading()
                HUD.error(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func claimUnstakeAction() {
        guard let delegatorId = provider.delegatorId else {
            return
        }
        
        if node.tokensUnstaked.decimalValue <= 0 {
            HUD.error(title: "stake_insufficient_balance".localized)
            return
        }
        
        Task {
            do {
                HUD.loading()
                let _ = try await StakingManager.shared.claimUnstake(nodeID: node.nodeID, delegatorId: delegatorId, amount: node.tokensUnstaked.decimalValue)
                HUD.dismissLoading()
            } catch {
                debugPrint(error)
                HUD.dismissLoading()
                HUD.error(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func restakeUnstakeAction() {
        guard let delegatorId = provider.delegatorId else {
            return
        }
        
        if node.tokensUnstaked.decimalValue <= 0 {
            HUD.error(title: "stake_insufficient_balance".localized)
            return
        }
        
        Task {
            do {
                HUD.loading()
                let _ = try await StakingManager.shared.reStakeUnstake(nodeID: node.nodeID, delegatorId: delegatorId, amount: node.tokensUnstaked.decimalValue)
                HUD.dismissLoading()
            } catch {
                debugPrint(error)
                HUD.dismissLoading()
                HUD.error(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func unstakeAction() {
        Router.route(to: RouteMap.Wallet.stakeAmount(provider, isUnstake: true))
    }
}
