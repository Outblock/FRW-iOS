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
    
    func insufficientStorageCheck() -> InsufficientStorageFailure? {
        insufficientStorageCheck(amount: 0, from: nil, to: nil)
    }
    
    func insufficientStorageCheck(amount: Decimal = 0, from fromContact: Contact, to toContact: Contact) -> InsufficientStorageFailure? {
        return insufficientStorageCheck(amount: amount, from: fromContact.walletType, to: toContact.walletType)
    }
    
    func insufficientStorageCheck(amount: Decimal = 0, from fromWallet: Contact.WalletType?, to toWallet: Contact.WalletType?) -> InsufficientStorageFailure? {
        let isTransferBetweenEvmAndFlow = switch (fromWallet, toWallet) {
        case (.flow, .evm), (.evm, .flow): true
        default: false
        }
        
        let wm = WalletManager.shared
        if (isTransferBetweenEvmAndFlow) {
            switch (wm.isBalanceInsufficient, wm.isBalanceInsufficient(for: amount)) {
            case (true, _): return .beforeTransfer
            case (false, true): return .afterTransfer
            case (false, false): return nil
            }
        } else {
            switch (wm.isStorageInsufficient, wm.isStorageInsufficient(for: amount)) {
            case (true, _): return .beforeTransfer
            case (false, true): return .afterTransfer
            case (false, false): return nil
            }
        }
    }
}

struct InsufficientStorageToastView<ViewModel: InsufficientStorageToastViewModel>: View {
    @EnvironmentObject private var viewModel: ViewModel
    
    var body: some View {
        PersistentToastView(message: self.viewModel.variant?.message ?? "", imageRes: .Storage.insufficient)
            .visibility(self.viewModel.showInsufficientFundsToast ? .visible : .gone)
    }
}

//#Preview {
//    InsufficientStorageToastView()
//}
