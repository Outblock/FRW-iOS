//
//  MoveTokenViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/27.
//

import SwiftUI

class MoveTokenViewModel: ObservableObject {
    @Published var inputDollarNum: Double = 0
    
    @Published var inputText: String = ""
    @Published var inputTokenNum: Double = 0
    @Published var amountBalance: Double = 0
    @Published var coinRate: Double = 0
    @Published var errorType: WalletSendAmountView.ErrorType = .none

    @Published var state: VPrimaryButtonState = .disabled
    @Published var enableButton: Bool = false
    @Published var isLoading: Bool = false
    
    var token: TokenModel
    
    init(token: TokenModel) {
        self.token = token
        refreshTokenData()
    }
    
    private func refreshTokenData() {
        amountBalance = WalletManager.shared.getBalance(bySymbol: token.symbol ?? "")
        coinRate = CoinRateCache.cache.getSummary(for: token.symbol ?? "")?.getLastRate() ?? 0
    }
    
    func inputTextDidChangeAction(text: String) {
        refreshSummary()
        updateState()
    }
    
    func refreshSummary() {
        if inputText.isEmpty {
            inputTokenNum = 0.0
            inputDollarNum = 0.0
            errorType = .none
            return
        }
        
        if !inputText.isNumber {
            inputTokenNum = 0.0
            inputDollarNum = 0.0
            errorType = .formatError
            return
        }
        inputTokenNum = inputText.doubleValue
        inputDollarNum = inputTokenNum * coinRate * CurrencyCache.cache.currentCurrencyRate
        if inputTokenNum > amountBalance {
            errorType = .insufficientBalance
            return
        }
        
        if amountBalance - inputTokenNum < 0.001 {
            errorType = .belowMinimum
            return
        }
        
    }
    
    func maxAction() {
        let num = max(amountBalance - 0.001, 0)
        inputText = num.formatCurrencyString()
        refreshSummary()
        updateState()
    }
    
    private func updateState() {
        enableButton  = isReadyForSend ? true : false
    }
     var isReadyForSend: Bool {
        return errorType == .none && inputText.isNumber && !inputText.isEmpty
    }
    
    var currentBalance: String {
        var str = ""
        if inputDollarNum > 0 {
            str += "Balance "
        }
        str += "$ \(inputDollarNum.formatCurrencyString())"
        return str
    }
}

extension MoveTokenViewModel {
    var showFromIcon: String {
        fromEVM ? evmIcon : walletIcon
    }

    var showFromName: String {
        fromEVM ? evmName : walletName
    }

    var showFromAddress: String {
        fromEVM ? evmAddress : walletAddress
    }
    
    var showToIcon: String {
        fromEVM ? walletIcon : evmIcon
    }
    
    var showToName: String {
        fromEVM ? walletName : evmName
    }
    
    var showToAddress: String {
        fromEVM ? walletAddress : evmAddress
    }
    
    var fromEVM: Bool {
        WalletManager.shared.isSelectedEVMAccount
    }
    
    private var walletIcon: String {
        UserManager.shared.userInfo?.avatar.convertedAvatarString() ?? ""
    }
    
    private var walletName: String {
        if let walletInfo = WalletManager.shared.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getName ?? "wallet".localized
        }
        return "wallet".localized
    }
    
    private var walletAddress: String {
        if let walletInfo = WalletManager.shared.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getAddress ?? "0x"
        }
        return "0x"
    }
    
    private var evmIcon: String {
        return EVMAccountManager.shared.accounts.first?.showIcon ?? ""
    }
    
    private var evmName: String {
        return EVMAccountManager.shared.accounts.first?.showName ?? ""
    }
    
    private var evmAddress: String {
        return EVMAccountManager.shared.accounts.first?.showAddress ?? ""
    }
    
    var balanceAsCurrentCurrencyString: String {
        return inputDollarNum.formatCurrencyString(considerCustomCurrency: true)
    }
}

extension MoveTokenViewModel {
    func onNext() {
        if token.isFlowCoin {
            if WalletManager.shared.isSelectedEVMAccount {
                withdrawCoa()
            }else {
                fundCoa()
            }
        }else {
            bridgeToken()
        }
        
    }
    
    private func withdrawCoa() {
        Task {
            do {
                log.info("[EVM] withdraw Coa balance")
                DispatchQueue.main.async {
                    self.enableButton = false
                    self.isLoading = true
                }
                let amount = self.inputTokenNum.decimalValue
                let txid = try await FlowNetwork.withdrawCoa(amount: amount)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                HUD.dismissLoading()
                Router.dismiss()
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.enableButton = true
                    self.isLoading = false
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.enableButton = true
                    self.isLoading = false
                }
                log.error("[EVM] move transation failed \(error)")
            }
        }
    }
    
    private func fundCoa() {
        Task {
            do {
                log.info("[EVM] fund Coa balance")
                DispatchQueue.main.async {
                    self.state = .loading
                }
                let amount = self.inputTokenNum.decimalValue
                let txid = try await FlowNetwork.fundCoa(amount: amount)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                
                Router.dismiss()
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.state = .enabled
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.state = .enabled
                }
                log.error("[EVM] move transation failed \(error)")
            }
        }
    }
    
    private func bridgeToken() {
        Task {
            do {
                log.info("[EVM] bridge token \(fromEVM ? "FromEVM" : "ToEVM")")
                let amount = self.inputTokenNum.decimalValue
        
                let address = (fromEVM ? token.evmBridgeAddress()   : token.getAddress()) ?? ""
                let name = fromEVM ? (token.evmBridgeContractName() ?? "") : token.contractName
                
                let txid = try await FlowNetwork.bridgeToken(address: address, contractName: name, amount: amount, fromEvm: fromEVM, decimals: token.decimal)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                
                Router.dismiss()
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.state = .enabled
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.state = .enabled
                }
                log.error("[EVM] move transation bridge token failed \(error)")
            }
        }
    }
}
