//
//  WalletViewModel.swift
//  Lilico
//
//  Created by cat on 2022/5/7.
//

import Combine
import Flow
import Foundation
import SwiftUI

extension WalletViewModel {
    enum WalletState {
        case idle
        case noAddress
        case loading
        case error
    }

    struct WalletCoinItemModel {
        let token: TokenModel
        let balance: Double
        let last: Double
        let changePercentage: Double

        var changeIsNegative: Bool {
            return changePercentage < 0
        }

        var changeString: String {
            let symbol = changeIsNegative ? "-" : "+"
            let num = String(format: "%.1f", fabsf(Float(changePercentage) * 100))
            return "\(symbol)\(num)%"
        }

        var changeColor: Color {
            return changeIsNegative ? Color.LL.Warning.warning2 : Color.LL.Success.success2
        }

        var balanceAsCurrentCurrency: String {
            return (balance * last).formatCurrencyString(considerCustomCurrency: true)
        }
    }
}

class WalletViewModel: ObservableObject {
    @Published var isHidden: Bool = LocalUserDefaults.shared.walletHidden
    @Published var balance: Double = 0
    @Published var coinItems: [WalletCoinItemModel] = []
    @Published var walletState: WalletState = .noAddress
    @Published var transactionCount: Int = LocalUserDefaults.shared.transactionCount
    @Published var pendingRequestCount: Int = 0
    @Published var backupTipsPresent: Bool = false
    
    private var lastRefreshTS: TimeInterval = 0
    private let autoRefreshInterval: TimeInterval = 30
    
    private var isReloading: Bool = false
    
    /// If the current account is not backed up, each time start app, backup tips will be displayed.
    private var backupTipsShown: Bool = false

    private var cancelSets = Set<AnyCancellable>()

    init() {
        WalletManager.shared.$walletInfo
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] newInfo in
                guard newInfo?.currentNetworkWalletModel?.getAddress != nil else {
                    self?.walletState = .noAddress
                    self?.balance = 0
                    self?.coinItems = []
                    return
                }
                
                self?.reloadWalletData()
            }.store(in: &cancelSets)

        WalletManager.shared.$coinBalances
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCoinItems()
            }.store(in: &cancelSets)
        
        WalletConnectManager.shared.$pendingRequests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.pendingRequestCount = WalletConnectManager.shared.pendingRequests.count
            }.store(in: &cancelSets)
        
        NotificationCenter.default.publisher(for: .walletHiddenFlagUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshHiddenFlag()
            }.store(in: &cancelSets)

        NotificationCenter.default.publisher(for: .coinSummarysUpdated)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshCoinItems()
            }.store(in: &cancelSets)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                
                if self.lastRefreshTS == 0 {
                    return
                }
                
                if abs(self.lastRefreshTS - Date().timeIntervalSince1970) > self.autoRefreshInterval {
                    self.reloadWalletData()
                }
            }.store(in: &cancelSets)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionCountDidChanged), name: .transactionCountDidChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReset), name: .didResetWallet, object: nil)
    }

    private func refreshHiddenFlag() {
        isHidden = LocalUserDefaults.shared.walletHidden
    }

    private func refreshCoinItems() {
        var list = [WalletCoinItemModel]()
        for token in WalletManager.shared.activatedCoins {
            guard let symbol = token.symbol else {
                continue
            }

            let summary = CoinRateCache.cache.getSummary(for: symbol)
            let item = WalletCoinItemModel(token: token,
                                           balance: WalletManager.shared.getBalance(bySymbol: symbol),
                                           last: summary?.getLastRate() ?? 0,
                                           changePercentage: summary?.getChangePercentage() ?? 0)
            list.append(item)
        }

        coinItems = list
        
        refreshTotalBalance()
        showBackupTipsIfNeeded()
    }
    
    private func refreshTotalBalance() {
        var total: Double = 0
        for item in coinItems {
            let asUSD = item.balance * item.last
            total += asUSD
        }
        
        balance = total
    }
    
    private func showBackupTipsIfNeeded() {
        if !UserManager.shared.isLoggedIn {
            return
        }
        
        guard let uid = UserManager.shared.activatedUID else { return }
        
        if MultiAccountStorage.shared.getBackupType(uid) != .none {
            return
        }
        
        if WalletManager.shared.coinBalances.isEmpty {
            return
        }
        
        if backupTipsShown {
            return
        }
        
        if backupTipsPresent {
            return
        }
        
        if balance < 0.01 {
            return
        }
        
        backupTipsPresent = true
        backupTipsShown = true
    }
    
    private func reloadTransactionCount() {
        Task {
            do {
                var count = try await LilicoAPI.Account.fetchAccountTransferCount()
                count += TransactionManager.shared.holders.count
                
                if count < LocalUserDefaults.shared.transactionCount {
                    return
                }
                
                let finalCount = count
                DispatchQueue.main.async {
                    LocalUserDefaults.shared.transactionCount = finalCount
                }
            } catch {
                debugPrint("WalletViewModel -> reloadTransactionCount, fetch transaction count failed: \(error)")
            }
        }
    }
    
    @objc private func transactionCountDidChanged() {
        DispatchQueue.syncOnMain {
            self.transactionCount = LocalUserDefaults.shared.transactionCount
        }
    }
    
    @objc private func willReset() {
        LocalUserDefaults.shared.transactionCount = 0
    }
    
    @objc private func didReset() {
        backupTipsShown = false
    }
}

// MARK: - Action

extension WalletViewModel {
    func reloadWalletData() {
        guard WalletManager.shared.getPrimaryWalletAddress() != nil else {
            return
        }
        
        if isReloading {
            return
        }
        
        isReloading = true
        
        log.debug("reloadWalletData")
        
        self.lastRefreshTS = Date().timeIntervalSince1970
        self.walletState = .idle
        
        Task {
            do {
                try await WalletManager.shared.fetchWalletDatas()
                self.reloadTransactionCount()
                
                DispatchQueue.main.async {
                    self.isReloading = false
                }
            } catch {
                log.error("reload wallet data failed", context: error)
                HUD.error(title: "fetch_wallet_error".localized)
                DispatchQueue.main.async {
                    self.walletState = .error
                    self.isReloading = false
                }
            }
        }
    }
    
    func copyAddressAction() {
        UIPasteboard.general.string = WalletManager.shared.selectedAccountAddress
        HUD.success(title: "copied".localized)
    }
    
    func toggleHiddenStatusAction() {
        LocalUserDefaults.shared.walletHidden = !isHidden
    }
    
    func scanAction() {
        ScanHandler.scan()
    }
    
    func stakingAction() {
        if !LocalUserDefaults.shared.stakingGuideDisplayed && !StakingManager.shared.isStaked {
            Router.route(to: RouteMap.Wallet.stakeGuide)
            return
        }
        
        Router.route(to: RouteMap.Wallet.stakingList)
    }
    
    func sideToggleAction() {
        NotificationCenter.default.post(name: .toggleSideMenu, object: nil)
    }
}
