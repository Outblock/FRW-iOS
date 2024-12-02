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
        case .beforeTransfer: return "insufficient_storage".localized
        case .afterTransfer: return "insufficient_storage_after_transfer".localized
        }
    }
}

// MARK: - InsufficientStorageToastViewModel

protocol InsufficientStorageToastViewModel: ObservableObject {
    var showInsufficientFundsToast: Bool { get }
    var variant: InsufficientStorageFailure? { get }
}

extension InsufficientStorageToastViewModel {
    var showInsufficientFundsToast: Bool { variant != nil }

    func insufficientStorageCheckForMove(
        from fromWallet: Contact.WalletType?,
        to toWallet: Contact.WalletType?
    ) -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, from: fromWallet, to: toWallet)
    }

    func insufficientStorageCheckForMove(
        amount: Decimal,
        from fromWallet: Contact.WalletType?,
        to toWallet: Contact.WalletType?
    ) -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: amount, from: fromWallet, to: toWallet)
    }

    func insufficientStorageCheckForTransfer() -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, from: nil, to: nil)
    }

    func insufficientStorageCheckForTransfer(amount: Decimal) -> InsufficientStorageFailure? {
        insufficientStorageCheckForMove(amount: amount, from: nil, to: nil)
    }

    private func insufficientStorageCheck(
        amount: Decimal,
        from fromWallet: Contact.WalletType?,
        to toWallet: Contact.WalletType?
    ) -> InsufficientStorageFailure? {
        let isTransferBetweenEvmAndFlow = switch (fromWallet, toWallet) {
        case (.flow, .evm), (.evm, .flow): true
        default: false
        }

        let wm = WalletManager.shared

        guard wm.isStorageInsufficient == false else {
            return .some(.beforeTransfer)
        }

        let transferAmount = isTransferBetweenEvmAndFlow ? amount + WalletManager.fixedMoveFee : 0

        guard wm.isBalanceInsufficient(for: transferAmount) == false else {
            return .some(.afterTransfer)
        }

        return .none
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
        .transition(AnyTransition.move(edge: .bottom))
        .task {
            withAnimation(.easeInOut(duration: 0.8).delay(0.4)) {
                self.isVisible = self.viewModel.showInsufficientFundsToast
            }
        }
        .hidden(!isVisible)
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
