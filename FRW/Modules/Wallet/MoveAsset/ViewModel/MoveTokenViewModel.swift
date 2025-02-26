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

final class MoveTokenViewModel: ObservableObject {
    // MARK: Lifecycle

    init(token: TokenModel, isPresent: Binding<Bool>) {
        self.token = token
        _isPresent = isPresent
        loadUserInfo()
        refreshTokenData()
        Task {
            await fetchMinFlowBalance()
            await updateTokenModel()
        }

        checkForInsufficientStorage()
    }

    // MARK: Internal

    @Published
    var inputDollarNum: Double = 0

    @Published
    var showBalance: String = ""
    var actualBalance: Decimal?

    @Published
    var inputTokenNum: Decimal = 0
    @Published
    var amountBalance: Decimal = 0
    @Published
    var coinRate: Double = 0
    @Published
    var errorType: WalletSendAmountView.ErrorType = .none

    @Published
    var loadingBalance: Bool = false

    @Published
    var buttonState: VPrimaryButtonState = .disabled

    private(set) var token: TokenModel

    @Binding
    var isPresent: Bool

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
            // Handle same account selection on from and to account
            // If so, we swap them
            if fromContact == toContact {
                toContact = oldValue
            }

            Task {
                await updateTokenModel()
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
            // Handle same account selection on from and to account
            // If so, we swap them
            if toContact == fromContact {
                fromContact = oldValue
            }
        }
    }

    var isReadyForSend: Bool {
        errorType == .none && showBalance.isNumber && !showBalance.isEmpty
    }

    var currentBalance: String {
        let totalStr = amountBalance.doubleValue.formatCurrencyString()
        return "\(totalStr)"
    }

    func updateTokenModel() async {
        guard let address = FWAddressDector.create(address: fromContact.address) else {
            return
        }
        do {
            await MainActor.run {
                self.loadingBalance = true
            }
            let tokens = try await TokenBalanceHandler.shared.getFTBalance(address: address)
            let tokenId = token.getId(by: address.type.toTokenType())
            var selectedToken: TokenModel = token
            if let target = tokens.first(where: { $0.id == tokenId }) {
                selectedToken = target
            } else {
                // Fallback to flow token
                if let flowToken = tokens.first(where: { $0.isFlowCoin }) {
                    selectedToken = flowToken
                }
            }

            await MainActor.run {
                self.loadingBalance = false
                self.changeTokenModelAction(token: selectedToken)
            }

        } catch {
            // TODO: Handle error
            log.error(error)
        }
    }

    func changeTokenModelAction(token: TokenModel) {
        self.token = token
        updateBalance("")
        errorType = .none
        refreshTokenData()
    }

    func inputTextDidChangeAction(text _: String) {
        if !maxButtonClickedOnce {
            actualBalance = Decimal(
                string: showBalance
            ) // showBalance.doubleValue
        }
        maxButtonClickedOnce = false
        refreshSummary()
        updateState()
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
            await MainActor.run {
                self.showBalance = num.doubleValue.formatCurrencyString()
                self.actualBalance = num
                self.refreshSummary()
                self.updateState()
            }
        }
    }

    func handleFromContact(_ contact: Contact) {
        let model = MoveAccountsViewModel(
            selected: fromContact.address ?? ""
        ) { newContact in
            if let contact = newContact {
                self.fromContact = contact
            }
        }
        Router.route(to: RouteMap.Wallet.chooseChild(model))
    }

    func handleToContact(_ contact: Contact) {
        let model = MoveAccountsViewModel(
            selected: toContact.address ?? ""
        ) { newContact in
            if let contact = newContact {
                self.toContact = contact
            }
        }
        Router.route(to: RouteMap.Wallet.chooseChild(model))
    }

    func handleSwap() {
        Task { @MainActor in
            (self.fromContact, self.toContact) = (self.toContact, self.fromContact)
        }
    }

    // MARK: Private

    private var minBalance: Decimal? = nil
    private var maxButtonClickedOnce = false
    private var _insufficientStorageFailure: InsufficientStorageFailure?

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

    private func refreshTokenData() {
        amountBalance = token.readableBalance ?? 0
        coinRate = CoinRateCache.cache
            .getSummary(by: token.contractId)?
            .getLastRate() ?? 0
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

    var toIsEVM: Bool {
        EVMAccountManager.shared.accounts
            .contains { $0.showAddress.lowercased() == toContact.address?.lowercased() }
    }

    var balanceAsCurrentCurrencyString: String {
        inputDollarNum.formatCurrencyString(considerCustomCurrency: true)
    }

    var showFee: Bool {
        !(fromContact.walletType == .link || toContact.walletType == .link)
    }
}

extension MoveTokenViewModel {
    func onNext() {
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
                    await MainActor.run {
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
            if WalletManager.shared.isSelectedEVMAccount {
                withdrawCoa()
            } else {
                fundCoa()
            }
        } else {
            bridgeToken()
        }
    }

    func onChooseAccount() {}

    private func withdrawCoa() {
        Task {
            do {
                log.info("[EVM] withdraw Coa balance")
                await MainActor.run {
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
                await MainActor.run {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            } catch {
                await MainActor.run {
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
                await MainActor.run {
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
                await MainActor.run {
                    self.closeAction()
                    self.buttonState = .enabled
                }
            } catch {
                await MainActor.run {
                    self.buttonState = .enabled
                }
                log.error("[EVM] move transation failed \(error)")
            }
        }
    }

    private func bridgeToken() {
        Task {
            do {
                await MainActor.run {
                    self.buttonState = .loading
                }
                log.info("[EVM] bridge token \(fromIsEVM ? "FromEVM" : "ToEVM")")

                guard let vaultIdentifier = token.vaultIdentifier else {
                    HUD.error(title: "failed".localized)
                    self.buttonState = .enabled
                    return
                }

                let amount = self.inputTokenNum // self.inputTokenNum.decimalValue
                let txid = try await FlowNetwork.bridgeToken(
                    vaultIdentifier: vaultIdentifier,
                    amount: amount,
                    fromEvm: fromIsEVM,
                    decimals: token.decimal
                )
                let holder = TransactionManager.TransactionHolder(id: txid, type: .transferCoin)
                TransactionManager.shared.newTransaction(holder: holder)

                WalletManager.shared.reloadWalletInfo()
                await MainActor.run {
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
                await MainActor.run {
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
