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
    @Published var walletName: String = "wallet".localized
    @Published var address: String = "0x0000000000000000"
    @Published var balance: Double = 0
    @Published var coinItems: [WalletCoinItemModel] = []
    @Published var walletState: WalletState = .noAddress
    @Published var transactionCount: Int = LocalUserDefaults.shared.transactionCount
    @Published var pendingRequestCount: Int = 0
    
    private var lastRefreshTS: TimeInterval = 0
    private let autoRefreshInterval: TimeInterval = 30

    private var cancelSets = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: .walletHiddenFlagUpdated).sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshHiddenFlag()
            }
        }.store(in: &cancelSets)

        WalletManager.shared.$walletInfo.sink { [weak self] newInfo in
            guard let address = newInfo?.currentNetworkWalletModel?.getAddress else {
                DispatchQueue.main.async {
                    self?.walletState = .noAddress
                    self?.address = "0x0000000000000000"
                    self?.balance = 0
                    self?.coinItems = []
                }
                return
            }

            if address != self?.address {
                DispatchQueue.main.async {
                    self?.refreshWalletInfo()
                    self?.reloadWalletData()
                }
            }
        }.store(in: &cancelSets)

        WalletManager.shared.$coinBalances.sink { [weak self] _ in
            if let self = self {
                DispatchQueue.main.async {
                    self.refreshCoinItems()
                }
            }
        }.store(in: &cancelSets)
        
        WalletConnectManager.shared.$pendingRequests.sink { [weak self] _ in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingRequestCount = WalletConnectManager.shared.pendingRequests.count
            }
        }.store(in: &cancelSets)

        NotificationCenter.default.publisher(for: .coinSummarysUpdated).sink { [weak self] _ in
            if let self = self {
                DispatchQueue.main.async {
                    self.refreshCoinItems()
                }
            }
        }.store(in: &cancelSets)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            guard let self = self else {
                return
            }
            
            if self.lastRefreshTS == 0 {
                return
            }
            
            DispatchQueue.main.async {
                if abs(self.lastRefreshTS - Date().timeIntervalSince1970) > self.autoRefreshInterval {
                    self.reloadWalletData()
                }
            }
        }.store(in: &cancelSets)
        
        NotificationCenter.default.addObserver(self, selector: #selector(transactionCountDidChanged), name: .transactionCountDidChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willReset), name: .willResetWallet, object: nil)
    }

    private func refreshHiddenFlag() {
        isHidden = LocalUserDefaults.shared.walletHidden
    }

    private func refreshWalletInfo() {
        if let walletInfo = WalletManager.shared.walletInfo?.currentNetworkWalletModel {
            walletName = walletInfo.getName ?? "wallet".localized
            address = walletInfo.getAddress ?? "0x0000000000000000"
        }
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
    }
    
    private func refreshTotalBalance() {
        var total: Double = 0
        for item in coinItems {
            let asUSD = item.balance * item.last
            total += asUSD
        }
        
        balance = total
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
        LocalUserDefaults.shared.walletHidden = false
    }
}

// MARK: - Action

extension WalletViewModel {
    func reloadWalletData() {
        guard WalletManager.shared.getPrimaryWalletAddress() != nil else {
            return
        }
        
        DispatchQueue.main.async {
            self.lastRefreshTS = Date().timeIntervalSince1970
            self.walletState = .idle
        }
        
        Task {
            do {
                try await WalletManager.shared.fetchWalletDatas()
                self.reloadTransactionCount()
            } catch {
                HUD.error(title: "fetch_wallet_error".localized)
                DispatchQueue.main.async {
                    self.walletState = .error
                }
            }
        }
    }
    
    func copyAddressAction() {
        UIPasteboard.general.string = address
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
