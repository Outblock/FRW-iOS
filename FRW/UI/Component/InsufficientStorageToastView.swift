//
//  InsufficientStorageToastView.swift
//  FRW
//
//  Created by Antonio Bello on 11/12/24.
//

import SwiftUI

enum InsufficientStorageFailure {
    case beforeTransfer, afterTransfer
    var message: String {
        switch self {
        case .beforeTransfer: return "insufficient_storage".localized
        case .afterTransfer: return "insufficient_storage_after_transfer".localized
        }
    }
}

protocol InsufficientStorageToastViewModel: ObservableObject {
    var showInsufficientFundsToast: Bool { get }
    var variant: InsufficientStorageFailure? { get }
}

extension InsufficientStorageToastViewModel {
    var showInsufficientFundsToast: Bool { self.variant != nil }
    
    func insufficientStorageCheckForMove(from fromWallet: Contact.WalletType?, to toWallet: Contact.WalletType?) -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, from: fromWallet, to: toWallet)
    }
    
    func insufficientStorageCheckForMove(amount: Decimal, from fromWallet: Contact.WalletType?, to toWallet: Contact.WalletType?) -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: amount, from: fromWallet, to: toWallet)
    }

    func insufficientStorageCheckForTransfer() -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, from: nil, to: nil)
    }
    
    func insufficientStorageCheckForTransfer(amount: Decimal) -> InsufficientStorageFailure? {
        insufficientStorageCheckForMove(amount: amount, from: nil, to: nil)
    }
    
    private func insufficientStorageCheck(amount: Decimal, from fromWallet: Contact.WalletType?, to toWallet: Contact.WalletType?) -> InsufficientStorageFailure? {
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

struct InsufficientStorageToastView<ViewModel: InsufficientStorageToastViewModel>: View {
    @EnvironmentObject private var viewModel: ViewModel
    @State private var isVisible = false
        
    var body: some View {
        VStack(spacing: 0) {
            if self.isVisible {
                PersistentToastView(message: self.viewModel.variant?.message ?? "", imageRes: .Storage.insufficient)
                    .transition(AnyTransition.move(edge: .bottom))
                    .hidden(!self.isVisible)
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 0.8).delay(0.8)) {
                self.isVisible = self.viewModel.showInsufficientFundsToast
            }
        }
    }
}

//#Preview {
//    InsufficientStorageToastView()
//}
