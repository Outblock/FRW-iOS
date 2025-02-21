//
//  MoveTokenViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/27.
//

import BigInt
import Flow
import SwiftUI

// MARK: - MoveTokenViewModel
@MainActor
final class MoveTokenViewModel: ObservableObject {
    // MARK: Lifecycle

    init(token: TokenModel, isPresent: Binding<Bool>) {
        self.token = token
        _isPresent = isPresent
        loadUserInfo()
        Task {
            await refreshTokenData()
            await fetchMinFlowBalance()
            checkForInsufficientStorage()
        }
    }

    // MARK: Internal

    @Published
    var showBalance: String = ""
    
    @Published
    var amountBalance: Decimal = 0

    @Published
    var buttonState: VPrimaryButtonState = .disabled
    
    @Published
    var supportedTokenList: [TokenModel] = []
    
    @Published
    private var coinBalances: [String: Double] = [:]

    @Published
    var fromContact = Contact(
        address: "",
        avatar: "",
        contactName: "",
        contactType: nil,
        domain: nil,
        id: -1,
        username: nil
    ) {
        didSet {
            guard fromContact != oldValue else { return }
            HUD.loading()
            if fromContact == toContact {
                toContact = oldValue
            }
            Task {
                await fetchCoinBalances()
                flipTokenVMIfNeeded()
                refreshTokenData()
                checkForInsufficientStorage()
                HUD.dismissLoading()
            }
        }
    }
    @Published
    var toContact = Contact(
        address: "",
        avatar: "",
        contactName: "",
        contactType: nil,
        domain: nil,
        id: -1,
        username: nil
    ) {
        didSet {
            guard toContact != oldValue else { return }
            if toContact == fromContact {
                fromContact = oldValue
            }
            checkForInsufficientStorage()
        }
    }

    private(set) var token: TokenModel
    @Binding
    var isPresent: Bool

    var isReadyForSend: Bool {
        errorType == .none && showBalance.isNumber && !showBalance.isEmpty
    }

    var currentBalance: String {
        let totalStr = amountBalance.doubleValue.formatCurrencyString()
        return "Balance: \(totalStr)"
    }
    
    private func flipTokenVMIfNeeded() {
        let needsFlipping = (fromIsEVM && token.type != .evm) || (!fromIsEVM && token.type == .evm)
        if needsFlipping, let flippedToken = WalletManager.shared.counterpartToken(for: token) {
            changeTokenModelAction(token: flippedToken)
        }
    }

    func changeTokenModelAction(token: TokenModel) {
        if token.contractId == self.token.contractId {
            return
        }
        self.token = token
        updateBalance("")
        errorType = .none
        Task {
            await refreshTokenData()
            refreshSummary()
        }
    }

    func inputTextDidChangeAction(text _: String) {
        if !maxButtonClickedOnce {
            actualBalance = Decimal(
                string: showBalance
            ) // showBalance.doubleValue
        }
        maxButtonClickedOnce = false
//        Task {
//            await refreshTokenData()
        refreshSummary()

            updateState()
//        }
    }

    func refreshSummary() {
        log.info("[refreshSummary]")
        if showBalance.isEmpty {
            inputTokenNum = 0
            inputDollarNum = 0.0
            errorType = .none
            return
        }

        if !showBalance.isNumber {
            inputTokenNum = 0
            inputDollarNum = 0.0
            errorType = .formatError
            return
        }

        inputTokenNum = actualBalance ?? Decimal(0)
        inputDollarNum = inputTokenNum.doubleValue * coinRate * CurrencyCache.cache
            .currentCurrencyRate

        checkForInsufficientStorage()

        if inputTokenNum > amountBalance {
            errorType = .insufficientBalance
            return
        }

        if !allowZero() && inputTokenNum == 0 {
            errorType = .insufficientBalance
            return
        }
        errorType = .none
    }

    func maxAction() {
        maxButtonClickedOnce = true
        Task {
            let num = await updateAmountIfNeed(inputAmount: amountBalance)
            DispatchQueue.main.async {
                self.showBalance = num.doubleValue.formatCurrencyString()
                self.actualBalance = num
                self.refreshSummary()
                self.updateState()
            }
        }
    }

    // MARK: Private

    private var minBalance: Decimal? = nil
    private var maxButtonClickedOnce = false
    private var _insufficientStorageFailure: InsufficientStorageFailure?
    
    @Published
    private var inputTokenNum: Decimal = 0
    @Published
    private var inputDollarNum: Double = 0
    @Published
    private var coinRate: Double = 0
    @Published
    private var errorType: WalletSendAmountView.ErrorType = .none
    private var actualBalance: Decimal?

    private func loadUserInfo() {
        guard let primaryAddr = WalletManager.shared.getPrimaryWalletAddressOrCustomWatchAddress()
        else {
            return
        }
        if let account = ChildAccountManager.shared.selectedChildAccount {
            fromContact = Contact(
                address: account.showAddress,
                avatar: account.icon,
                contactName: nil,
                contactType: .user,
                domain: nil,
                id: UUID().hashValue,
                username: account.showName,
                walletType: .link
            )
        } else if let account = EVMAccountManager.shared.selectedAccount {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            fromContact = Contact(
                address: account.showAddress,
                avatar: nil,
                contactName: nil,
                contactType: .user,
                domain: nil,
                id: UUID().hashValue,
                username: account.showName,
                user: user,
                walletType: .evm
            )
        } else {
            let user = WalletManager.shared.walletAccount.readInfo(at: primaryAddr)
            fromContact = Contact(
                address: primaryAddr,
                avatar: nil,
                contactName: nil,
                contactType: .user,
                domain: nil,
                id: UUID().hashValue,
                username: user.name,
                user: user,
                walletType: .flow
            )
        }

        if ChildAccountManager.shared.selectedChildAccount != nil || EVMAccountManager.shared
            .selectedAccount != nil {
            let user = WalletManager.shared.walletAccount.readInfo(at: primaryAddr)
            toContact = Contact(
                address: primaryAddr,
                avatar: nil,
                contactName: nil,
                contactType: .user,
                domain: nil,
                id: UUID().hashValue,
                username: user.name,
                user: user,
                walletType: .flow
            )
        } else if let account = EVMAccountManager.shared.accounts.first {
            let user = WalletManager.shared.walletAccount.readInfo(at: account.showAddress)
            toContact = Contact(
                address: account.showAddress,
                avatar: nil,
                contactName: nil,
                contactType: .user,
                domain: nil,
                id: UUID().hashValue,
                username: account.showName,
                user: user,
                walletType: .evm
            )
        } else if let account = ChildAccountManager.shared.childAccounts.first {
            toContact = Contact(
                address: account.showAddress,
                avatar: account.icon,
                contactName: nil,
                contactType: .user,
                domain: nil,
                id: UUID().hashValue,
                username: account.showName,
                walletType: .link
            )
        }
    }

    private func fetchMinFlowBalance() async {
        do {
            minBalance = try await FlowNetwork.minFlowBalance().decimalValue
            log.debug("[Flow] min balance:\(minBalance ?? 0.001)")
        } catch {
            minBalance = 0.001
        }
    }

    private func updateBalance(_ text: String) {
        guard !text.isEmpty else {
            showBalance = ""
            actualBalance = 0
            return
        }
    }
    
    private func fetchCoinBalances() async {
        do {
            coinBalances = try await FlowNetwork.fetchBalance(at: Flow.Address(hex: fromContact.address ?? ""))
            let evmTokens = try await EVMAccountManager.shared.fetchTokens().map { ($0.address, $0.flowBalance.doubleValue) }
            coinBalances = coinBalances.merging(evmTokens, uniquingKeysWith: { a, _ in return a })
            supportedTokenList = WalletManager.shared.supportedCoins(forType: fromIsEVM ? .evm : .cadence) ?? []
            if fromIsEVM, let flowToken = EVMAccountManager.fakeEVMFlowToken {
                supportedTokenList.append(flowToken)
            }
        } catch {
            log.error(error)
        }
    }
    
    private func refreshTokenData() {
        if fromIsEVM, token.isFlowCoin {
            amountBalance = EVMAccountManager.shared.balance
        } else if fromIsEVM, let balance = coinBalances[token.getAddress() ?? ""] {
            amountBalance = Decimal(balance)
        } else if let balance = coinBalances[token.contractId] {
            amountBalance = Decimal(balance)
        } else {
            amountBalance = 0
        }
        coinRate = CoinRateCache.cache
            .getSummary(by: token.contractId)?
            .getLastRate() ?? 0
        refreshSummary()
    }

    private func isFromFlowToCoa() -> Bool {
        token.isFlowCoin && fromContact.walletType == .flow && toContact.walletType == .evm
    }

    private func allowZero() -> Bool {
        guard isFromFlowToCoa() else {
            return true
        }
        return false
    }

    private func updateAmountIfNeed(inputAmount: Decimal) async -> Decimal {
        guard isFromFlowToCoa() else {
            return max(inputAmount, 0)
        }
        if minBalance == nil {
            HUD.loading()
            await fetchMinFlowBalance()
            HUD.dismissLoading()
        }
        // move fee
        let num = max(
            inputAmount - (
                minBalance ?? WalletManager.minFlowBalance
            ) - WalletManager.fixedMoveFee,
            0
        )
        return num
    }

    private func updateState() {
        DispatchQueue.main.async {
            self.buttonState = self.isReadyForSend ? .enabled : .disabled
        }
    }
}

// MARK: InsufficientStorageToastViewModel

extension MoveTokenViewModel: InsufficientStorageToastViewModel {
    var variant: InsufficientStorageFailure? { _insufficientStorageFailure }

    private func checkForInsufficientStorage() {
        _insufficientStorageFailure = insufficientStorageCheckForMove(
            amount: inputTokenNum,
            token: .ft(token),
            from: fromContact.walletType,
            to: toContact.walletType,
            isMove: true
        )
    }
}

extension MoveTokenViewModel {
    var fromIsEVM: Bool {
        EVMAccountManager.shared.accounts
            .contains { $0.showAddress.lowercased() == fromContact.address?.lowercased() }
    }

    var showFee: Bool {
        !(fromContact.walletType == .link || toContact.walletType == .link)
    }
}

extension MoveTokenViewModel {
    func onNext() {
//        checkForInsufficientStorage()
        if fromContact.walletType == .link || toContact.walletType == .link {
            Task {
                do {
                    var tid: Flow.ID?
                    let amount = self.inputTokenNum //
                    let vaultIdentifier = (
                        fromIsEVM ? (token.flowIdentifier ?? "") : token
                            .contractId + ".Vault"
                    )
                    switch (fromContact.walletType, toContact.walletType) {
                    case (.link, .evm):
                        tid = try await FlowNetwork
                            .bridgeChildTokenToCoa(
                                vaultIdentifier: vaultIdentifier,
                                child: fromContact.address ?? "",
                                amount: amount
                            )
                    case (.evm, .link):
                        tid = try await FlowNetwork
                            .bridgeChildTokenFromCoa(
                                vaultIdentifier: vaultIdentifier,
                                child: toContact.address ?? "",
                                amount: amount,
                                decimals: token.decimal
                            )
                    default:
                        break
                    }

                    if let txid = tid {
                        let holder = TransactionManager.TransactionHolder(
                            id: txid,
                            type: .moveAsset
                        )
                        TransactionManager.shared.newTransaction(holder: holder)
                        EventTrack.Transaction
                            .ftTransfer(
                                from: fromContact.address ?? "",
                                to: toContact.address ?? "",
                                type: token.symbol ?? "",
                                amount: amount.doubleValue,
                                identifier: token.contractId
                            )
                    }
                    DispatchQueue.main.async {
                        self.closeAction()
                        self.buttonState = .enabled
                    }
                } catch {
                    log
                        .error(
                            " Move Token: \(fromContact.walletType?.rawValue ?? "") to  \(toContact.walletType?.rawValue ?? "") failed. \(error)"
                        )
                    log.error(error)
                    buttonState = .enabled
                }
            }
        }
        if token.isFlowCoin {
            if fromContact.walletType == .evm {
                withdrawCoa()
            } else {
                fundCoa()
            }
        } else {
            bridgeToken()
        }
    }

    private func withdrawCoa() {
        Task {
            do {
                log.info("[EVM] withdraw Coa balance")
                DispatchQueue.main.async {
                    self.buttonState = .loading
                }
                let amount = self.inputTokenNum // self.inputTokenNum.decimalValue
                let txid = try await FlowNetwork.withdrawCoa(amount: amount)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                HUD.dismissLoading()
                EventTrack.Transaction
                    .ftTransfer(
                        from: fromContact.address ?? "",
                        to: toContact.address ?? "",
                        type: token.symbol ?? "",
                        amount: amount.doubleValue,
                        identifier: token.contractId
                    )
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            } catch {
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
                let maxAmount = await updateAmountIfNeed(
                    inputAmount: amountBalance
                )
                guard maxAmount >= self.inputTokenNum else {
                    HUD.error(title: "Insufficient_balance::message".localized)
                    return
                }
                DispatchQueue.main.async {
                    self.buttonState = .loading
                }
                let amount = self.inputTokenNum // self.inputTokenNum.decimalValue
                log.debug("[amount] move \(self.inputTokenNum)")
                log.debug("[amount] move \(amount.description)")
                let txid = try await FlowNetwork.fundCoa(amount: amount)
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)
                EventTrack.Transaction
                    .ftTransfer(
                        from: fromContact.address ?? "",
                        to: toContact.address ?? "",
                        type: token.symbol ?? "",
                        amount: amount.doubleValue,
                        identifier: token.contractId
                    )
                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            } catch {
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
                // TODO:

                DispatchQueue.main.async {
                    self.buttonState = .loading
                }
                log.info("[EVM] bridge token \(fromIsEVM ? "FromEVM" : "ToEVM")")
                let amount = self.inputTokenNum // self.inputTokenNum.decimalValue

                let vaultIdentifier = (
                    fromIsEVM ? (token.flowIdentifier ?? "") : token
                        .contractId + ".Vault"
                )
                let txid = try await FlowNetwork.bridgeToken(
                    vaultIdentifier: vaultIdentifier,
                    amount: amount,
                    fromEvm: fromIsEVM,
                    decimals: token.decimal
                )
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)

                WalletManager.shared.reloadWalletInfo()
                DispatchQueue.main.async {
                    self.closeAction()
                    self.buttonState = .enabled
                }
                EventTrack.Transaction
                    .ftTransfer(
                        from: fromContact.address ?? "",
                        to: toContact.address ?? "",
                        type: token.symbol ?? "",
                        amount: amount.doubleValue,
                        identifier: token.contractId
                    )

            } catch {
                DispatchQueue.main.async {
                    self.buttonState = .enabled
                }
                log.error("[EVM] move transation bridge token failed \(error)")
            }
        }
    }

    func closeAction() {
        Router.dismiss {
            MoveAssetsAction.shared.endBrowser()
        }
    }
}
