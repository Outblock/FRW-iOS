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

    @Published var buttonState: VPrimaryButtonState = .disabled
    
    @Published var fromContact: Contact = Contact(address: "", avatar: "", contactName: "", contactType: nil, domain: nil, id: -1, username: nil)
    @Published var toContact: Contact = Contact(address: "", avatar: "", contactName: "", contactType: nil, domain: nil, id: -1, username: nil)
    
    var token: TokenModel
    @Binding var isPresent: Bool
    
    init(token: TokenModel, isPresent: Binding<Bool>) {
        self.token = token
        _isPresent = isPresent
        loadUserInfo()
        refreshTokenData()
    }
    
    private func loadUserInfo() {
        guard let primaryAddr = WalletManager.shared.getPrimaryWalletAddressOrCustomWatchAddress() else {
            return
        }
        if let account = ChildAccountManager.shared.selectedChildAccount {
            fromContact = Contact(address: account.showAddress, avatar: account.icon, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName, walletType: .link)
        }else if let account = EVMAccountManager.shared.selectedAccount {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            fromContact = Contact(address: account.showAddress, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,user: user, walletType: .evm)
        }else  {
            let user = WalletManager.shared.walletAccount.readInfo(at: primaryAddr)
            fromContact = Contact(address: primaryAddr, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: user.name, user: user, walletType: .flow)
        }
        
        
        if ChildAccountManager.shared.selectedChildAccount != nil || EVMAccountManager.shared.selectedAccount != nil {
            let user = WalletManager.shared.walletAccount.readInfo(at: primaryAddr)
            toContact = Contact(address: primaryAddr, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: user.name,user: user, walletType: .flow)
        }else if let account = EVMAccountManager.shared.accounts.first {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            toContact = Contact(address: account.showAddress, avatar: nil, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName,user: user, walletType: .evm)
        }else if let account = ChildAccountManager.shared.childAccounts.first {
            toContact = Contact(address: account.showAddress, avatar: account.icon, contactName: nil, contactType: .user, domain: nil, id: UUID().hashValue, username: account.showName, walletType: .link)
        }
    }
    
    func changeTokenModelAction(token: TokenModel) {
        if token.contractId == self.token.contractId {
            return
        }
        self.token = token
        inputText = ""
        errorType = .none
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
        
//        if amountBalance - inputTokenNum < 0.001 {
//            errorType = .belowMinimum
//            return
//        }
        errorType = .none
    }
    
    func maxAction() {
        let num = max(amountBalance, 0)
        inputText = num.formatCurrencyString()
        refreshSummary()
        updateState()
    }
    
    private func updateState() {
        buttonState = isReadyForSend ? .enabled : .disabled
    }

    var isReadyForSend: Bool {
        return errorType == .none && inputText.isNumber && !inputText.isEmpty
    }
    
    var currentBalance: String {
        let totalStr = amountBalance.formatCurrencyString()
        return "Balance: \(totalStr)"
    }
}

extension MoveTokenViewModel {
    
    var fromIsEVM: Bool {
        EVMAccountManager.shared.accounts.contains { $0.showAddress == fromContact.address }
    }
    
    var toIsEVM: Bool {
        EVMAccountManager.shared.accounts.contains { $0.showAddress == toContact.address }
    }
    
    var balanceAsCurrentCurrencyString: String {
        return inputDollarNum.formatCurrencyString(considerCustomCurrency: true)
    }
}

extension MoveTokenViewModel {
    func onNext() {
        //TODO: #six 新的cadence
        if fromContact.walletType == .link || toContact.walletType == .link {
            HUD.info(title: "Features are coming.")
            return
        }
        if token.isFlowCoin {
            if WalletManager.shared.isSelectedEVMAccount {
                withdrawCoa()
            }
            else {
                fundCoa()
            }
        }
        else {
            bridgeToken()
        }
    }
    
    func onChooseAccount() {
        
    }
    
    private func withdrawCoa() {
        Task {
            do {
                log.info("[EVM] withdraw Coa balance")
                DispatchQueue.main.async {
                    self.buttonState = .loading
                }
                let amount = self.inputTokenNum.decimalValue
                let txid = try await FlowNetwork.withdrawCoa(amount: amount)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                HUD.dismissLoading()
                
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.buttonState = .enabled
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
                    self.buttonState = .loading
                }
                let amount = self.inputTokenNum.decimalValue
                let txid = try await FlowNetwork.fundCoa(amount: amount)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.buttonState = .enabled
                }
                log.error("[EVM] move transation failed \(error)")
            }
        }
    }
    
    private func bridgeToken() {
        Task {
            do {
                //TODO:
                
                DispatchQueue.main.async {
                    self.buttonState = .loading
                }
                log.info("[EVM] bridge token \(fromIsEVM ? "FromEVM" : "ToEVM")")
                let amount = self.inputTokenNum.decimalValue
        
                let address = (fromIsEVM ? token.evmBridgeAddress() : token.getAddress()) ?? ""
                let name = fromIsEVM ? (token.evmBridgeContractName() ?? "") : token.contractName
                
                let txid = try await FlowNetwork.bridgeToken(address: address, contractName: name, amount: amount, fromEvm: fromIsEVM, decimals: token.decimal)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            }
            catch {
                DispatchQueue.main.async {
                    self.buttonState = .enabled
                }
                log.error("[EVM] move transation bridge token failed \(error)")
            }
        }
    }
    
    func closeAction() {
        Router.dismiss(){
            MoveAssetsAction.shared.endBrowser()
        }
    }
}
