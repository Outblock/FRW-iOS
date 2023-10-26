//
//  AccountKeyRevokeView.swift
//  FRW
//
//  Created by cat on 2023/10/26.
//

import SwiftUI

struct AccountKeyRevokeView: View {
    
    @EnvironmentObject var vm: AccountKeyViewModel
    
    var body: some View {
        VStack {
            SheetHeaderView(title: "account_key_revoke_title".localized)
            
            VStack(spacing: 0) {
                Text("account_key_revoke_content".localized)
                    .font(.inter(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Theme.Accent.red)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.Theme.Accent.red)
                
                
                
                Spacer()
                
                WalletSendButtonView(allowEnable: .constant(true)) {
                    vm.revokeKeyAction()
                }
                    .padding(.bottom, 10)
                Button {
                    vm.cancelRevoke()
                } label: {
                    Text("not_now".localized)
                        .font(.inter(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.Theme.Text.black8)
                }

            }
            .padding(.horizontal, 28)
        }
        .backgroundFill(Color.LL.Neutrals.background)
    }
}

#Preview {
    AccountKeyRevokeView()
}
