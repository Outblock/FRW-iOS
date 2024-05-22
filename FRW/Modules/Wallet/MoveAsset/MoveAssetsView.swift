//
//  MoveAssetsView.swift
//  FRW
//
//  Created by cat on 2024/5/17.
//

import SwiftUI
import SwiftUIX

struct MoveAssetsView: View {
    var closeAction: () -> ()
    
    var body: some View {
        VStack {
            TitleWithClosedView(title: "move_assets".localized, closeAction: {
                closeAction()
            })
            .padding(.top, 24)
            
            Text("move_assets_note_x".localized(toName()))
                .font(.inter(size: 14))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Theme.Text.black8)
            
            HStack {
                Button {
                    closeAction()
                    Router.route(to: RouteMap.Wallet.moveNFTs)
                } label: {
                    card(isNFT: true)
                }
                .buttonStyle(ScaleButtonStyle())

                Spacer()
                Button {
                    closeAction()
                } label: {
                    card(isNFT: false)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.top, 32)
            
            Button  {
                closeAction()
            } label: {
                HStack {
                    Text("maybe_later_text")
                        .font(.inter(size: 16))
                        .foregroundStyle(Color.Theme.Text.black8)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .padding(.top, 24)

            Spacer()
        }
        .padding(.horizontal,18)
        .background(Color.Theme.Background.grey)
        .cornerRadius([.topLeading, .topTrailing], 16)
        .ignoresSafeArea()
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
}

#Preview {
    MoveAssetsView(){}
}
