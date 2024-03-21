//
//  MoveTokenViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/27.
//

import SwiftUI

class MoveTokenViewModel: ObservableObject {
    @Published var isReadyForSend: Bool = false
    
    
}

extension MoveTokenViewModel {
    var showFromIcon: String {
        WalletManager.shared.selectedAccountIcon
    }
    var showFromName: String {
        WalletManager.shared.selectedAccountWalletName
    }
    var showFromAddress: String {
        WalletManager.shared.selectedAccountAddress
    }
    var fromEVM: Bool {
        WalletManager.shared.isSelectedEVMAccount
    }
}
