//
//  StakeAmountViewModel.swift
//  Lilico
//
//  Created by Selina on 2/12/2022.
//

import SwiftUI
import Flow

extension StakeAmountViewModel {
    enum ErrorType {
        case none
        case insufficientBalance
        case belowMinimumBalance
        case belowMinimumAmount
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            case .belowMinimumBalance:
                // TODO: Use localized to replace
                return "The balance cannot be less than 0.001"
            case .belowMinimumAmount:
                return "50 FLOW minimum required"
            }
        }
    }
}

class StakeAmountViewModel: ObservableObject {
    @Published var provider: StakingProvider
    @Published var isUnstake: Bool
    
    @Published var inputText: String = ""
    @Published var inputTextNum: Double = 0
    @Published var balance: Double = 0
    @Published var showConfirmView: Bool = false
    @Published var errorType: StakeAmountViewModel.ErrorType = .none
    
    @Published var isRequesting: Bool = false
    
    var buttonState: VPrimaryButtonState {
        if isRequesting {
            return .loading
        }
        return .enabled
    }
    
    var inputNumAsUSD: Double {
        let rate = CoinRateCache.cache.getSummary(for: "flow")?.getLastRate() ?? 0
        return inputTextNum * rate
    }
    
    var inputNumAsCurrencyString: String {
        return "\(CurrencyCache.cache.currencySymbol)\(inputNumAsUSD.formatCurrencyString(considerCustomCurrency: true)) \(CurrencyCache.cache.currentCurrency.rawValue)"
    }
    
    var inputNumAsCurrencyStringInConfirmSheet: String {
        return "\(CurrencyCache.cache.currencySymbol)\(inputNumAsUSD.formatCurrencyString(considerCustomCurrency: true))"
    }
    
    var yearReward: Double {
        inputTextNum * provider.rate
    }
    
    var yearRewardFlowString: String {
        yearReward.formatCurrencyString()
    }
    
    var yearRewardWithCurrencyString: String {
        let numString = (inputNumAsUSD * provider.rate).formatCurrencyString(considerCustomCurrency: true)
        return "\(CurrencyCache.cache.currencySymbol)\(numString) \(CurrencyCache.cache.currentCurrency.rawValue)"
    }
    
    var isReadyForStake: Bool {
        return errorType == .none && inputTextNum > 0
    }
    
    init(provider: StakingProvider, isUnstake: Bool) {
        self.provider = provider
        self.isUnstake = isUnstake
        balance = isUnstake ? (provider.currentNode?.stakingCount ?? 0) : WalletManager.shared.getBalance(bySymbol: "flow")
    }
    
    private func refreshState() {
        if inputTextNum > balance {
            errorType = .insufficientBalance
            return
        }
        
        if balance - inputTextNum < 0.001, !isUnstake {
            errorType = .belowMinimumBalance
            return
        }
        
        if inputTextNum < 50, !isUnstake {
            errorType = .belowMinimumAmount
            return
        }
        
        errorType = .none
    }
}

extension StakeAmountViewModel {
    func inputTextDidChangeAction(text: String) {
        let filtered = text.filter {"0123456789.".contains($0)}
        
        if filtered.contains(".") {
            let splitted = filtered.split(separator: ".")
            if splitted.count >= 2 {
                let preDecimal = String(splitted[0])
                let afterDecimal = String(splitted[1])
                inputText = "\(preDecimal).\(afterDecimal)"
            } else {
                inputText = filtered
            }
        } else {
            inputText = filtered
        }
        
        inputTextNum = Double(inputText) ?? 0
        refreshState()
    }
    
    func percentAction(percent: Double) {
        inputText = "\((balance * percent).formatCurrencyString())"
    }
    
    func confirmSetupAction() {
        Router.dismiss()
        
        Task {
            if await StakingManager.shared.stakingSetup() == false {
                debugPrint("StakeAmountViewModel: setup account staking failed.")
                DispatchQueue.main.async {
                    HUD.error(title: StakingError.stakingSetupFailed.desc)
                }
            } else {
                debugPrint("StakeAmountViewModel: setup account staking success.")
                DispatchQueue.main.async {
                    self.confirmStakeAction()
                }
            }
        }
    }
    
    func stakeBtnAction() {
        UIApplication.shared.endEditing()
        
        if showConfirmView {
            showConfirmView = false
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showConfirmView = true
        }
    }
    
    private func stakingSetup() {
        Router.route(to: RouteMap.Wallet.stakeSetupConfirm(self))
    }
    
    private func stake() async throws -> Flow.ID {
        // check account staking is setup
        if !StakingManager.shared.isSetup {
            debugPrint("StakeAmountViewModel: account staking not setup")
            throw StakingError.stakingNeedSetup
        }
        
        if provider.delegatorId == nil {
            debugPrint("StakeAmountViewModel: provider.delegatorId is nil, will create delegator id")
            // create delegator id to stake (only first time)
            if try await FlowNetwork.createDelegatorId(providerId: provider.id) == false {
                debugPrint("StakeAmountViewModel: createDelegatorId failed")
                throw StakingError.stakingCreateDelegatorIdFailed
            }
            
            debugPrint("StakeAmountViewModel: create delegator id success, refresh delegator info after 2 seconds")
            
            // create delegator id success, delay 2 seconds then refresh delegatorIds
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            try await StakingManager.shared.refreshDelegatorInfo()
            
            debugPrint("StakeAmountViewModel: refreshDelegatorInfo success")
        }
        
        guard let delegatorId = provider.delegatorId else {
            // can not be nil, something went wrong.
            debugPrint("StakeAmountViewModel: delegatorId is still nil after fetch delegatorIds, something went wrong")
            throw StakingError.unknown
        }
        
        debugPrint("StakeAmountViewModel: provider.delegatorId now get, will stake flow")
        
        let txId = try await FlowNetwork.stakeFlow(providerId: provider.id, delegatorId: delegatorId, amount: inputTextNum)
        return txId
        
    }
    
    private func unstake() async throws -> Flow.ID {
        if provider.delegatorId == nil {
            debugPrint("StakeAmountViewModel: provider.delegatorId is nil, will create delegator id")
            // create delegator id to stake (only first time)
            if try await FlowNetwork.createDelegatorId(providerId: provider.id) == false {
                debugPrint("StakeAmountViewModel: createDelegatorId failed")
                throw StakingError.stakingCreateDelegatorIdFailed
            }
            
            debugPrint("StakeAmountViewModel: create delegator id success, refresh delegator info after 2 seconds")
            
            // create delegator id success, delay 2 seconds then refresh delegatorIds
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            try await StakingManager.shared.refreshDelegatorInfo()
            
            debugPrint("StakeAmountViewModel: refreshDelegatorInfo success")
        }
        
        guard let delegatorId = provider.delegatorId else {
            // can not be nil, something went wrong.
            debugPrint("StakeAmountViewModel: delegatorId is still nil after fetch delegatorIds, something went wrong")
            throw StakingError.unknown
        }
        
        debugPrint("StakeAmountViewModel: provider.delegatorId now get, will unstake flow")
        
        let txId = try await FlowNetwork.unstakeFlow(providerId: provider.id, delegatorId: delegatorId, amount: inputTextNum)
        return txId
    }
    
    func confirmStakeAction() {
        if isRequesting {
            return
        }
        
        isRequesting = true
        
        let failureBlock: (String) -> Void = { errorMsg in
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: errorMsg)
            }
        }
        
        let successBlock: (Flow.ID) -> Void = { txId in
            DispatchQueue.main.async {
                self.isRequesting = false
                self.showConfirmView = false
                let holder = TransactionManager.TransactionHolder(id: txId, type: .stakeFlow, data: Data())
                TransactionManager.shared.newTransaction(holder: holder)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    Router.route(to: RouteMap.Wallet.backToTokenDetail)
                }
            }
        }
        
        Task {
            do {
                // check staking is enabled
                if try await FlowNetwork.stakingIsEnabled() == false {
                    debugPrint("StakeAmountViewModel: staking is disabled")
                    throw StakingError.stakingDisabled
                }
                
                let txId = isUnstake ? try await unstake() : try await stake()
                successBlock(txId)
            } catch StakingError.stakingNeedSetup {
                // run staking setup logic
                DispatchQueue.main.async {
                    self.isRequesting = false
                    self.stakingSetup()
                }
            } catch let error as StakingError {
                debugPrint("StakeAmountViewModel: catch StakingError \(error)")
                failureBlock(error.desc)
            } catch {
                debugPrint("StakeAmountViewModel: catch extra error \(error)")
                failureBlock("request_failed".localized)
            }
        }
    }
}
