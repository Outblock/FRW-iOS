//
//  WalletSendAmountViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 13/7/2022.
//

import Foundation
import SwiftUI
import Flow

import Combine

extension WalletSendAmountView {
    enum ExchangeType {
        case token
        case dollar
    }
    
    enum ErrorType {
        case none
        case insufficientBalance
        case formatError
        case invalidAddress
        case belowMinimum
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            case .formatError:
                return "format_error".localized
            case .invalidAddress:
                return "invalid_address".localized
            case .belowMinimum:
                return "below_minimum_error".localized
            }
        }
    }
}

class WalletSendAmountViewModel: ObservableObject {
    @Published var targetContact: Contact
    @Published var token: TokenModel
    @Published var amountBalance: Double = 0
    @Published var coinRate: Double = 0
    
    @Published var inputText: String = ""
    @Published var inputTokenNum: Double = 0
    @Published var inputDollarNum: Double = 0
    
    @Published var exchangeType: WalletSendAmountView.ExchangeType = .token
    @Published var errorType: WalletSendAmountView.ErrorType = .none
    
    @Published var showConfirmView: Bool = false
    
    @Published var isValidToken: Bool = true
    
    @Published var isEmptyTransation = true
    
    private var isSending = false
    private var cancelSets = Set<AnyCancellable>()
    
    private var addressIsValid: Bool?
    
    private var minBalance: Double = 0.001
    
    init(target: Contact, token: TokenModel) {
        self.targetContact = target
        self.token = token
        
        WalletManager.shared.$coinBalances.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshTokenData()
                self?.refreshInput()
            }
        }.store(in: &cancelSets)
        checkAddress()
        checkTransaction()
        fetchMinFlowBalance()
        NotificationCenter.default.addObserver(self, selector: #selector(onHolderChanged(noti:)), name: .transactionStatusDidChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var amountBalanceAsDollar: Double {
        return coinRate * amountBalance
    }
    
    var isReadyForSend: Bool {
        return errorType == .none && inputText.isNumber && addressIsValid == true
    }
}

extension WalletSendAmountViewModel {
    private func checkAddress() {
        Task {
            if let address = targetContact.address {
                var isValidAddr = address.isEVMAddress
                if !isValidAddr {
                    isValidAddr = await FlowNetwork.addressVerify(address: address)
                }
                let isValid = isValidAddr
                DispatchQueue.main.async {
                    self.addressIsValid = isValid
                    if isValid == false {
                        self.errorType = .invalidAddress
                    } else {
                        self.checkToken()
                    }
                }
            }
        }
    }
    
    private func checkToken() {
        Task {
            if let address = targetContact.address {
                if address.isEVMAddress {
                    DispatchQueue.main.async {
                        //TODO: need check logic is right?
                        self.isValidToken = self.token.isFlowCoin
                    }
                    return
                }
                let list = try await FlowNetwork.checkTokensEnable(address: Flow.Address(hex: address))
                let model = list.first { $0.key.lowercased() == token.contractId.lowercased() }
                let isValid = model?.value
                DispatchQueue.main.async {
                    self.isValidToken = isValid ?? false
                }
            }
        }
    }
    
    private func refreshTokenData() {
        amountBalance = WalletManager.shared.getBalance(bySymbol: token.symbol ?? "")
        coinRate = CoinRateCache.cache.getSummary(for: token.symbol ?? "")?.getLastRate() ?? 0
    }
    
    private func refreshInput() {
        if errorType == .invalidAddress {
            return
        }
        
        if inputText.isEmpty {
            errorType = .none
            return
        }
        
        if !inputText.isNumber {
            inputDollarNum = 0
            inputTokenNum = 0
            errorType = .formatError
            return
        }
        
        if exchangeType == .token {
            inputTokenNum = inputText.doubleValue
            inputDollarNum = inputTokenNum * coinRate * CurrencyCache.cache.currentCurrencyRate
        } else {
            inputDollarNum = inputText.doubleValue
            if coinRate == 0 {
                inputTokenNum = 0
            } else {
                inputTokenNum = inputDollarNum / CurrencyCache.cache.currentCurrencyRate / coinRate
            }
        }
        
        if inputTokenNum > amountBalance {
            errorType = .insufficientBalance
            return
        }
        
        if token.isFlowCoin && EVMAccountManager.shared.selectedAccount == nil {
            
            if amountBalance - inputTokenNum < minBalance  {
                errorType = .belowMinimum
                return
            }
        }
        
        errorType = .none
    }
    
    private func saveToRecentLlist() {
        RecentListCache.cache.append(contact: targetContact)
    }
    
    private func fetchMinFlowBalance()  {
        Task {
            do {
                self.minBalance = try await FlowNetwork.minFlowBalance()
                log.debug("[Flow] min balance:\(self.minBalance)")
            }catch {
                self.minBalance = 0.001
            }
        }
    }
}

extension WalletSendAmountViewModel {
    func inputTextDidChangeAction(text: String) {
//        let filtered = text.filter {"0123456789.".contains($0)}
//        
//        if filtered.contains(".") {
//            let splitted = filtered.split(separator: ".")
//            if splitted.count >= 2 {
//                let preDecimal = String(splitted[0])
//                let afterDecimal = String(splitted[1])
//                inputText = "\(preDecimal).\(afterDecimal)"
//            } else {
//                inputText = filtered
//            }
//        } else {
//            inputText = filtered
//        }
        
        refreshInput()
    }
    
    func maxAction() {
        exchangeType = .token
        if token.isFlowCoin && EVMAccountManager.shared.selectedAccount == nil {
            Task {
                do {
                    let topAmount = try await FlowNetwork.minFlowBalance()
                    let num = max(amountBalance - topAmount, 0)
                    inputText = num.formatCurrencyString()
                }catch {
                    let num = max(amountBalance - minBalance, 0)
                    inputText = num.formatCurrencyString()
                    log.error("[Flow] min flow balance error")
                }
            }
        }else {
            let num = max(amountBalance, 0)
            inputText = num.formatCurrencyString()
        }
    }
    
    func toggleExchangeTypeAction() {
        if exchangeType == .token, coinRate != 0 {
            exchangeType = .dollar
            inputText = inputDollarNum.formatCurrencyString()
        } else {
            exchangeType = .token
            inputText = inputTokenNum.formatCurrencyString()
        }
    }
    
    func nextAction() {
        UIApplication.shared.endEditing()
        
        if showConfirmView {
            showConfirmView = false
        }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showConfirmView = true
        }
    }
    
    func sendWithVerifyAction() {
        if SecurityManager.shared.securityType == .none {
            doSend()
            return
        }
        
        Task {
            let result = await SecurityManager.shared.inAppVerify()
            if !result {
                HUD.error(title: "verify_failed".localized)
                return
            }
            
            DispatchQueue.main.async {
                self.doSend()
            }
        }
    }
    
    private func doSend() {
        if isSending {
            return
        }
        
        guard let address = WalletManager.shared.getPrimaryWalletAddress(), let targetAddress = targetContact.address else {
            return
        }
        
        let failureBlock = {
            DispatchQueue.main.async {
                self.isSending = false
                HUD.dismissLoading()
                HUD.error(title: "send_failed".localized)
            }
        }
        
        saveToRecentLlist()
        
        isSending = true
        
        Task {
            do {
                
                let fromEVM = WalletManager.shared.isSelectedEVMAccount
                let toEVM = targetAddress.isEVMAddress
                let flowToFlow = !fromEVM && !toEVM
                let flowToCoa = !fromEVM && toEVM && (targetAddress == EVMAccountManager.shared.accounts.first?.address)
                let coaToFlow = fromEVM && !toEVM
                let coaToCoa = fromEVM && toEVM
                let flowToEoa = !fromEVM && toEVM && (targetAddress != EVMAccountManager.shared.accounts.first?.address)
                
                var txId: Flow.ID?
                let amount = inputTokenNum.decimalValue
                if flowToFlow {
                    txId = try await FlowNetwork.transferToken(to: Flow.Address(hex: targetContact.address ?? "0x"),
                                                                 amount: amount,
                                                                 token: token)
                }else if flowToCoa {
                    // Move 1 fundCoa()
                    txId = try await FlowNetwork.fundCoa(amount: amount)
                }else if coaToFlow {
                    // Move 2 withdrawCoa()
                    txId = try await FlowNetwork.withdrawCoa(amount: amount)
                }else if coaToCoa {
                    // evmCall check
                    txId = try await FlowNetwork.sendTransaction(amount: amount.description, data: nil, toAddress: targetAddress.stripHexPrefix(), gas: 100000)
                }else if flowToEoa {
                    // transferFlowToEvmAddress
                    txId = try await FlowNetwork.sendFlowToEvm(evmAddress: targetAddress.stripHexPrefix(), amount: amount, gas: 100000)
                }
                
                guard let id = txId else {
                    failureBlock()
                    return
                }
                
                
                DispatchQueue.main.async {
                    let obj = CoinTransferModel(amount: self.inputTokenNum, symbol: self.token.symbol ?? "", target: self.targetContact, from: address)
                    guard let data = try? JSONEncoder().encode(obj) else {
                        debugPrint("WalletSendAmountViewModel -> obj encode failed")
                        failureBlock()
                        return
                    }
                    
                    self.isSending = false
                    HUD.dismissLoading()
                    self.showConfirmView = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Router.dismiss()
                    }
                    
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                    
                    let holder = TransactionManager.TransactionHolder(id: id, type: .transferCoin, data: data)
                    TransactionManager.shared.newTransaction(holder: holder)
                }
            } catch {
                debugPrint("WalletSendAmountViewModel -> sendAction error: \(error)")
                failureBlock()
                showConfirmView = false
            }
        }
    }
    
    func changeTokenModelAction(token: TokenModel) {
        LocalUserDefaults.shared.recentToken = token.symbol
        
        self.token = token
        refreshTokenData()
        refreshInput()
    }
}

extension WalletSendAmountViewModel {
    func checkTransaction() {
        isEmptyTransation = TransactionManager.shared.holders.count == 0
    }
 
    @objc private func onHolderChanged(noti: Notification) {
        checkTransaction()
    }
}

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result = String.numberFormatter.number(from: self) {
            return result.doubleValue
        }else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
