//
//  SwapViewModel.swift
//  Flow Reference Wallet
//
//  Created by Selina on 23/9/2022.
//

import SwiftUI

private let TimerDelay: TimeInterval = 0.4

extension SwapViewModel {
    enum ErrorType {
        case none
        case insufficientBalance
        
        var desc: String {
            switch self {
            case .none:
                return ""
            case .insufficientBalance:
                return "insufficient_balance".localized
            }
        }
    }
}

class SwapViewModel: ObservableObject {
    @Published var inputFromText: String = ""
    @Published var inputToText: String = ""
    @Published var fromToken: TokenModel?
    @Published var toToken: TokenModel?
    @Published var isRequesting: Bool = false
    @Published var isConfirming: Bool = false
    @Published var estimateResponse: SwapEstimateResponse?
    @Published var errorType: SwapViewModel.ErrorType = .none
    @Published var showConfirmView: Bool = false
    
    var oldInputFromText: String = ""
    var oldInputToText: String = ""
    
    private var timer: Timer?
    private var requestIsFromInput: Bool = true
    
    init(defaultFromToken: TokenModel?) {
        self.fromToken = defaultFromToken
    }
    
    var buttonState: VPrimaryButtonState {
        if isRequesting {
            return .loading
        }
        
        return isValidToSwap ? .enabled : .disabled
    }
    
    var confirmButtonState: VPrimaryButtonState {
        if isConfirming {
            return .loading
        }
        
        return .enabled
    }
    
    var isValidToSwap: Bool {
        guard fromToken != nil, toToken != nil, fromAmount != 0, toAmount != 0 else {
            return false
        }
        
        return errorType == .none
    }
    
    var rateText: String {
        guard let fromToken = fromToken, let toToken = toToken, let response = estimateResponse else {
            return ""
        }
        
        guard let amountIn = response.routes.first??.routeAmountIn, let amountOut = response.routes.first??.routeAmountOut else {
            return ""
        }
        
        return "1 \(fromToken.symbol?.uppercased() ?? "") ≈ \((amountOut / amountIn).formatCurrencyString()) \(toToken.symbol?.uppercased() ?? "")"
    }
    
    var fromAmount: Double {
        return Double(inputFromText) ?? 0
    }
    
    var toAmount: Double {
        return Double(inputToText) ?? 0
    }
    
    var fromTokenRate: Double {
        return CoinRateCache.cache.getSummary(for: fromToken?.symbol ?? "")?.getLastRate() ?? 0
    }
    
    var toTokenRate: Double {
        return CoinRateCache.cache.getSummary(for: toToken?.symbol ?? "")?.getLastRate() ?? 0
    }
    
    var fromPriceAmountString: String {
        return (fromAmount * fromTokenRate).formatCurrencyString(considerCustomCurrency: true)
    }
}

extension SwapViewModel {
    private func requestEstimate(isFromInput: Bool) {
        requestIsFromInput = isFromInput
        
        guard fromToken != nil, toToken != nil else {
            stopTimer()
            return
        }
        
        if fromAmount == 0, toAmount == 0 {
            stopTimer()
            return
        }
        
        self.estimateResponse = nil
        startTimer()
    }
    
    @objc private func doRequestEstimate() {
        guard let fromToken = fromToken, let toToken = toToken else {
            return
        }
        
        if fromAmount == 0, toAmount == 0 {
            return
        }
        
        let localIsFromInput = requestIsFromInput
        let localFromAmount = fromAmount
        let localToAmount = toAmount
        
        isRequesting = true
        
        Task {
            do {
                let request = SwapEstimateRequest(inToken: fromToken.contractId, outToken: toToken.contractId, inAmount: localIsFromInput ? fromAmount : nil, outAmount: localIsFromInput ? nil : toAmount)
                let response: SwapEstimateResponse = try await Network.request(FRWWebEndpoint.swapEstimate(request))
                
                DispatchQueue.main.async {
                    self.isRequesting = false
                    
                    if fromToken.contractId != self.fromToken?.contractId || toToken.contractId != self.toToken?.contractId || localIsFromInput != self.requestIsFromInput {
                        // invalid response
                        return
                    }
                    
                    if localIsFromInput, localFromAmount != self.fromAmount {
                        // invalid response
                        return
                    }
                    
                    if !localIsFromInput, localToAmount != self.toAmount {
                        // invalid response
                        return
                    }
                    
                    if localIsFromInput {
                        self.oldInputToText = "\(response.tokenOutAmount.formatCurrencyString())"
                        self.inputToText = "\(response.tokenOutAmount.formatCurrencyString())"
                    } else {
                        self.oldInputFromText = "\(response.tokenInAmount.formatCurrencyString())"
                        self.inputFromText = "\(response.tokenInAmount.formatCurrencyString())"
                    }
                    
                    self.estimateResponse = response
                    self.refreshInput()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRequesting = false
                    HUD.error(title: "swap_request_failed".localized)
                }
            }
        }
    }
    
    private func startTimer() {
        stopTimer()
        
        let timer = Timer(timeInterval: TimerDelay, target: self, selector: #selector(doRequestEstimate), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    private func refreshInput() {
        guard let fromTokenSymbol = fromToken?.symbol else {
            return
        }
        
        if fromAmount > WalletManager.shared.getBalance(bySymbol: fromTokenSymbol) {
            errorType = .insufficientBalance
        } else {
            errorType = .none
        }
    }
}

extension SwapViewModel {
    func inputFromTextDidChangeAction(text: String) {
        if text == oldInputFromText {
            return
        }
        
        let filtered = text.filter {"0123456789.".contains($0)}
        
        if filtered.contains(".") {
            let splitted = filtered.split(separator: ".")
            if splitted.count >= 2 {
                let preDecimal = String(splitted[0])
                let afterDecimal = String(splitted[1])
                inputFromText = "\(preDecimal).\(afterDecimal)"
            } else {
                inputFromText = filtered
            }
        } else {
            inputFromText = filtered
        }
        
        oldInputFromText = inputFromText
        refreshInput()
        requestEstimate(isFromInput: true)
    }
    
    func inputToTextDidChangeAction(text: String) {
        if text == oldInputToText {
            return
        }
        
        let filtered = text.filter {"0123456789.".contains($0)}
        
        if filtered.contains(".") {
            let splitted = filtered.split(separator: ".")
            if splitted.count >= 2 {
                let preDecimal = String(splitted[0])
                let afterDecimal = String(splitted[1])
                inputToText = "\(preDecimal).\(afterDecimal)"
            } else {
                inputToText = filtered
            }
        } else {
            inputToText = filtered
        }
        
        oldInputToText = inputToText
        refreshInput()
        requestEstimate(isFromInput: false)
    }
    
    func selectTokenAction(isFrom: Bool) {
        var disableTokens = [TokenModel]()
        if let toToken = toToken, isFrom {
            disableTokens.append(toToken)
        }
        
        if let fromToken = fromToken, !isFrom {
            disableTokens.append(fromToken)
        }
        
        Router.route(to: RouteMap.Wallet.selectToken(isFrom ? fromToken : toToken, disableTokens, { selectedToken in
            if isFrom {
                self.fromToken = selectedToken
                self.refreshInput()
            } else {
                self.toToken = selectedToken
            }
            
            self.requestEstimate(isFromInput: isFrom)
        }))
    }
    
    func switchTokenAction() {
        guard let fromToken = fromToken, let toToken = toToken else {
            return
        }
        
        UIApplication.shared.endEditing()
        
        self.fromToken = toToken
        self.toToken = fromToken
        self.refreshInput()
        self.requestEstimate(isFromInput: !self.requestIsFromInput)
    }
    
    func maxAction() {
        guard let symbol = fromToken?.symbol else {
            return
        }
        
        self.inputFromText = WalletManager.shared.getBalance(bySymbol: symbol).formatCurrencyString()
    }
    
    func swapAction() {
        showConfirmView = true
    }
    
    func confirmSwapAction() {
        guard let response = estimateResponse, let fromToken = fromToken, let toToken = toToken else {
            return
        }
        
        isConfirming = true
        
        Task {
            do {
                let tokenKeyFlatSplitPath = response.tokenKeyFlatSplitPath
                let amountInSplit = response.amountInSplit
                let amountOutSplit = response.amountOutSplit
                let deadline = Decimal(Date().timeIntervalSince1970 + 60 * 10)
                let slippageRate = 0.1
                let estimateOut = response.tokenOutAmount
                let amountOutMin = Decimal(Double((estimateOut * (1.0 - slippageRate))))
                let storageIn = fromToken.storagePath
                let storageOut = toToken.storagePath
                let estimateIn = response.tokenInAmount
                let amountInMax = Decimal(Double((estimateIn / (1.0 - slippageRate))))
                
                let txid = try await FlowNetwork.swapToken(swapPaths: tokenKeyFlatSplitPath, tokenInMax: amountInMax, tokenOutMin: amountOutMin, tokenInVaultPath: String(storageIn.vault.split(separator: "/").last ?? ""), tokenOutSplit: amountOutSplit, tokenInSplit: amountInSplit, tokenOutVaultPath: String(storageOut.vault.split(separator: "/").last ?? ""), tokenOutReceiverPath: String(storageOut.receiver.split(separator: "/").last ?? ""), tokenOutBalancePath: String(storageOut.balance.split(separator: "/").last ?? ""), deadline: deadline, isFrom: self.requestIsFromInput)
                
                let data = try JSONEncoder().encode(response)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .common, data: data)
                
                DispatchQueue.main.async {
                    self.isConfirming = false
                    self.showConfirmView = false
                    TransactionManager.shared.newTransaction(holder: holder)
                    
                    // Wait for half sheet dismiss first
                    delay(.seconds(1)) {
                        Router.dismiss()
                    }
                }
            } catch {
                debugPrint("SwapViewModel -> confirmSwapAction failed: \(error)")
                HUD.error(title: "swap_request_failed".localized)
                DispatchQueue.main.async {
                    self.isConfirming = false
                }
            }
        }
    }
}
