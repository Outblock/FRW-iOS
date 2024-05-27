//
//  AccountSideCell.swift
//  FRW
//
//  Created by cat on 2024/5/27.
//

import SwiftUI
import Kingfisher

struct AccountSideCell: View {
    
    enum Action {
        case card
        case arrow
    }
    
    var address: String
    var currentAddress: String
    var logo: String? = nil
    var detail: String? = nil
    var onClick:(String, AccountSideCell.Action) -> ()
    
    private var network: LocalUserDefaults.FlowNetworkType {
        LocalUserDefaults.shared.flowNetwork
    }
    
    private var emoji: WalletAccount.Emoji {
        WalletManager.shared.walletAccount.readInfo(at: address)
    }
    
    private var isSelected: Bool {
        
        if address == currentAddress {
            return true
        }
        return false
    }
    
    private var isEVM: Bool {
        if let evmAddress = EVMAccountManager.shared.accounts.first?.showAddress {
            return evmAddress == address
        }
        return false
    }
    
    
    var body: some View {
        
        Button {
            NotificationCenter.default.post(name: .toggleSideMenu)
            onClick(address, .card)
            
        } label: {
            HStack(spacing: 0) {
                if let logoUrl = logo {
                    KFImage.url(URL(string: logoUrl))
                        .placeholder {
                            Image("placeholder")
                                .resizable()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                        .cornerRadius(12)
                }else {
                    emoji.icon()
                        .padding(.trailing,18)
                }
                
                    
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(emoji.name)
                            .font(.inter(size: 14))
                            .foregroundStyle(Color.Theme.Text.black8)
                            .frame(height: 22)
                        
                        EVMTagView()
                            .visibility(isEVM ? .visible : .gone)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(Color.Theme.Accent.green)
                            .visibility(isSelected ? .visible : .gone)
                            
                    }
                    
                    Text(detail ?? address)
                        .font(.inter(size: 12))
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundStyle(Color.Theme.Text.black3)
                        .frame(height: 20)
                        
                }
                Spacer()
                
//                Image("device_arrow_right")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 8, height: 14)
                
            }
            .padding(18)
            .frame(height: 82)
//            .background {
//                LinearGradient(colors: [
//                    Color.Theme.Accent.green.opacity(0.08),
//                    Color.Theme.Accent.green.opacity(0)
//                ],
//                               startPoint: .leading,
//                               endPoint: .trailing)
//                    .visibility(isSelected ? .visible : .gone)
//            }
        }
    }
}

#Preview {
    AccountSideCell(address: WalletManager.shared.getFlowNetworkTypeAddress(network: .mainnet) ?? "", currentAddress: "", onClick: {str, action in })
}
