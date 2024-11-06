//
//  EVMEnableSheetView.swift
//  FRW
//
//  Created by cat on 11/6/24.
//

import SwiftUI

struct EVMEnableSheetView: RouteableView & PresentActionDelegate {
    
    var changeHeight: (() -> Void)?
    
    var title: String {
        ""
    }
    
    var isNavigationBarHidden: Bool {
        true
    }
    
    var callback: BoolClosure
    
    
    var body: some View {
        GeometryReader { _ in
            VStack(alignment: .leading,spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        HStack {
                            Color.clear
                                .frame(width: 24, height: 24)
                            Spacer()
                            Text("Quick Enable EVM".localized)
                                .font(.inter(size: 24, weight: .bold))
                                .foregroundStyle(Color.Theme.Text.black)
                                .padding(.top, 6)
                            Spacer()
                            
                            Button {
                                onClose()
                            } label: {
                                Image("icon_close_circle_gray")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.top, 8)
                        
                        Image("evm_small_planet")
                            .resizable()
                            .frame(width: 220, height: 220)
                            .padding(.top, 16)
                        
                        Text("enable_evm_tip".localized)
                            .font(.inter(size: 14))
                            .foregroundStyle(Color.Theme.Text.black8)
                            .padding(.top, 6)
                        
                        VPrimaryButton(model: ButtonStyle.evmEnable,
                                       state: .enabled,
                                       action: {
                            onEnable()
                        }, title: "enable".localized)
                        .frame(width: 160)
                        .padding(.top, 22)
                        
                        Button {
                            onClose()
                        } label: {
                            Text("not_now".localized)
                                .font(.inter(size: 16))
                                .foregroundStyle(Color.Theme.Text.black8)
                        }
                        .padding(.top)
                        .padding(.bottom)
                        
                        Spacer()
                    }
                    .padding(18)
                }
            }
            .backgroundFill(Color.Theme.BG.bg1)
            .cornerRadius([.topLeading, .topTrailing], 16)
            .edgesIgnoringSafeArea(.bottom)
           
        }
        .applyRouteable(self)
    }
    
    private func onClose() {
        Router.dismiss()
    }
    
    private func onEnable() {
        let minBalance = 0.000
        let result = WalletManager.shared.activatedCoins.filter { tokenModel in
            if tokenModel.isFlowCoin, let symbol = tokenModel.symbol {
                log.debug("[EVM] enable check balance: \(WalletManager.shared.getBalance(bySymbol: symbol))")
                return WalletManager.shared.getBalance(bySymbol: symbol) >= minBalance
            }
            return false
        }
        guard result.count == 1 else {
            HUD.error(title: "", message: "evm_check_balance".localized)
            return
        }
        
        Task {
            do {
                try await EVMAccountManager.shared.enableEVM()
                await EVMAccountManager.shared.refreshSync()
                EVMAccountManager.shared.select(EVMAccountManager.shared.accounts.first)
                onClose()
            } catch {
                HUD.error(title: "Enable EVM failed.")
                log.error("Enable EVM failer: \(error)")
            }
        }
    }
    
    
}

#Preview {
    EVMEnableSheetView() { result in
        
    }
}
