//
//  MoveAssetsView.swift
//  FRW
//
//  Created by cat on 2024/5/17.
//

import SwiftUI
import SwiftUIX

struct MoveAssetsView: RouteableView,PresentActionDelegate {
    
    var title: String {
        return ""
    }
    
    var token: TokenModel?
    var showCheck: Bool {
        MoveAssetsAction.shared.showCheckOnMoveAsset
    }
    
    var showNote: String {
        if let note = MoveAssetsAction.shared.showNote {
            return note
        }
        return "move_assets_note".localized
    }
    
    @State private var notAsk: Bool = LocalUserDefaults.shared.showMoveAssetOnBrowser {
        didSet {
            LocalUserDefaults.shared.showMoveAssetOnBrowser = notAsk
        }
    }
    
    
    var body: some View {
        VStack {
            TitleWithClosedView(title: "move_assets".localized, closeAction: {
                Router.dismiss(animated: true, completion: {
                    MoveAssetsAction.shared.endBrowser()
                })
            })
            .padding(.top, 24)
            
            Text(showNote)
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
                } label: {
                    card(isNFT: false)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.top, 32)
            
            Color.clear
                .frame(width: 1, height: 24)
            
            if showCheck {
                HStack {
                    if notAsk {
                        Image("icon_check_rounde_0")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(Color.Theme.Text.black8)
                        .frame(width: 16, height: 16)
                    }else {
                        Image("icon_check_rounde_1")
                        .resizable()
                        .frame(width: 16, height: 16)
                    }
                        
                    Text("do_not_ask".localized)
                        .font(.inter(size: 16))
                        .foregroundStyle(Color.Theme.Text.black8)
                    
                }
                .onTapGesture {
                    notAsk.toggle()
                }
            }
            
            
            
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
    }
    
    func customViewDidDismiss() {
        MoveAssetsAction.shared.endBrowser()
    }
}

#Preview {
    MoveAssetsView(token: TokenModel.mock())
        
}
