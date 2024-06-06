//
//  MoveAssetsView.swift
//  FRW
//
//  Created by cat on 2024/5/17.
//

import SwiftUI
import SwiftUIX

struct MoveAssetsView: RouteableView {
    
    var title: String {
        return ""
    }
    
    
    var token: TokenModel?
    var showToken: () ->()
    var closeAction: () -> ()
    
    var body: some View {
        VStack {
            TitleWithClosedView(title: "move_assets".localized, closeAction: {
                onClose()
            })
            .padding(.top, 24)
            
            Text("move_assets_note".localized)
                .font(.inter(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Theme.Text.black8)
            
            HStack {
                Button {
                    onClose()
                    Router.route(to: RouteMap.Wallet.moveNFTs)
                } label: {
                    card(isNFT: true)
                }
                .buttonStyle(ScaleButtonStyle())

                Spacer()
                Button {
                    if let current = currentToken() {
                        onClose()
                        Router.route(to: RouteMap.Wallet.moveToken(current))
                    }else {
                        HUD.error(title: "not found token")
                    }
                    
//                    showToken()
                } label: {
                    card(isNFT: false)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.top, 32)
            

            Spacer()
        }
        .padding(.horizontal,18)
        .background(Color.Theme.Background.grey)
        .cornerRadius([.topLeading, .topTrailing], 16)
        .ignoresSafeArea()
        .applyRouteable(self)
    }
    
    func toName() -> String {
        EVMAccountManager.shared.selectedAccount == nil ? "Flow" : "EVM"
    }
    
    @ViewBuilder
    func card(isNFT: Bool) -> some View {
        VStack {
            Image(isNFT ? "evm_move_nft_header" : "evm_move_token_header")
                .resizable()
                .aspectRatio(contentMode: .fit)
                
            
            Text(isNFT ? "move_nft".localized : "move_token".localized )
                .font(.inter(size: 18, weight: .semibold))
                .foregroundStyle(Color.Theme.Text.black)
        }
        .frame(width: 164, height: 224)
        .background {
            Image("move_assets_bg_\(isNFT ? "0" : "1")")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 164, height: 224)
        }
        
    }
        
    private func currentToken() -> TokenModel? {
        if let current = token {
            return current
        }
        if let current = WalletManager.shared.activatedCoins.first {
            return current
        }
        return nil
    }
    
    private func onClose() {
        Router.dismiss()
//        closeAction()
    }
}

#Preview {
    MoveAssetsView(token: TokenModel.mock()) {
        
    } closeAction: {
        
    }
    
}
