//
//  InsufficientStorageToastView.swift
//  FRW
//
//  Created by Antonio Bello on 11/12/24.
//

import SwiftUI

// MARK: - InsufficientStorageFailure

enum InsufficientStorageFailure {
    case beforeTransfer, afterTransfer

    // MARK: Internal

    var message: String {
        switch self {
        case .beforeTransfer: return "insufficient_storage_error".localized
        case .afterTransfer: return "insufficient_storage_after_transfer_error".localized
        }
    }

    var showAlert: (Double) -> Void {
        return switch self {
        case .beforeTransfer: AlertViewController
            .showInsufficientStorageWarningBefore(minimumBalance:)
        case .afterTransfer: AlertViewController
            .showInsufficientStorageWarningAfter(minimumBalance:)
        }
    }
}

// MARK: - InsufficientStorageToastViewModel

protocol InsufficientStorageToastViewModel: ObservableObject {
    var showInsufficientFundsToast: Bool { get }
    var variant: InsufficientStorageFailure? { get }
}

extension InsufficientStorageToastViewModel {
    private var isTransactionWarningPredictionEnabled: Bool {
        RemoteConfigManager.shared.config?.features.transactionWarningPrediction ?? false
    }

    private var isShowWarning: Bool {
        isTransactionWarningPredictionEnabled && WalletManager.shared.isSelectedFlowAccount
    }

    var showInsufficientFundsToast: Bool {
        variant != nil
    }

    func insufficientStorageCheckForMove(
        token: TokenType,
        from fromWallet: Contact.WalletType?,
        to toWallet: Contact.WalletType?
    ) -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, token: token, from: fromWallet, to: toWallet)
    }

    func insufficientStorageCheckForMove(
        amount: Decimal,
        token: TokenType,
        from fromWallet: Contact.WalletType?,
        to toWallet: Contact.WalletType?,
        isMove: Bool = false
    ) -> InsufficientStorageFailure? {
        insufficientStorageCheck(
            amount: amount,
            token: token,
            from: fromWallet,
            to: toWallet,
            isMove: isMove
        )
    }

    func insufficientStorageCheckForTransfer(token: TokenType) -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, token: token, from: nil, to: nil)
    }

    func insufficientStorageCheckForTransfer(
        amount: Decimal,
        token: TokenType
    ) -> InsufficientStorageFailure? {
        insufficientStorageCheckForMove(amount: amount, token: token, from: nil, to: nil)
    }

    private func insufficientStorageCheck(
        amount: Decimal,
        token: TokenType,
        from fromWallet: Contact.WalletType?,
        to toWallet: Contact.WalletType?,
        isMove: Bool = false
    ) -> InsufficientStorageFailure? {
        let wm = WalletManager.shared

        // Pre-transaction warning

        guard wm.isStorageInsufficient == false else {
            return .some(.beforeTransfer)
        }

        // Post-transaction prediction warning

        guard isShowWarning else { return .none }

        let isTransferBetweenEvmAndFlow = switch (fromWallet, toWallet) {
        case (.evm, .flow), (.flow, .evm): true
        case (.evm, _): false
        case (.flow, _): false
        case (.link, _): false
        case (.none, _): false
        }

        let isFlowToken = switch token {
        case let .ft(token): token.isFlowCoin
        case .nft: false
        case .none: false
        }

        let transferAmount: Decimal = switch (isFlowToken, isTransferBetweenEvmAndFlow) {
        case (true, true): amount + (isMove ? WalletManager.fixedMoveFee : 0)
        case (true, false): amount
        case (false, _): 0
        }

        guard wm.isBalanceInsufficient(for: transferAmount) == false else {
            return .some(.afterTransfer)
        }

        guard wm.isFlowInsufficient(for: transferAmount) == false else {
            return .some(.afterTransfer)
        }

        return .none
    }

    func showWarningAlert() {
        guard showInsufficientFundsToast else { return }
        variant?.showAlert(WalletManager.shared.minimumStorageBalance.doubleValue)
    }
}

// MARK: - InsufficientStorageToastView

struct InsufficientStorageToastView<ViewModel: InsufficientStorageToastViewModel>: View {
    // MARK: Internal

    var body: some View {
        PersistentToastView(
            message: viewModel.variant?.message ?? "",
            imageRes: .Storage.insufficient
        )
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
        .transition(.push(from: .bottom))
        .hidden(!isVisible)
        .task {
            withAnimation(.easeInOut(duration: 0.8).delay(0.8)) {
                self.isVisible = self.viewModel.showInsufficientFundsToast
            }
        }
        .visibility(viewModel.showInsufficientFundsToast ? .visible : .gone)
        .environment(\.openURL, OpenURLAction { _ in
            self.viewModel.showWarningAlert()
            return .handled
        })
    }

    // MARK: Private

    @EnvironmentObject
    private var viewModel: ViewModel
    @State
    private var isVisible = false
}

// #Preview {
//    InsufficientStorageToastView()
// }
