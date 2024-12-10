//
//  AccountKeyRevokeView.swift
//  FRW
//
//  Created by cat on 2023/10/26.
//

import SwiftUI

struct AccountKeyRevokeView: View {
    @EnvironmentObject
    var vm: AccountKeyViewModel

    var body: some View {
        VStack {
            SheetHeaderView(title: "account_key_revoke_title".localized)

            VStack(spacing: 0) {
                Text("account_key_revoke_content".localized)
                    .font(.inter(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Theme.Accent.red)
                Image("icon_key_revoke")
                    .frame(width: 64, height: 64)
                    .padding(.top, 24)

                Spacer()

                WalletSendButtonView(
                    allowEnable: .constant(true),
                    buttonText: "hold_to_revoke".localized,
                    activeColor: Color.Theme.Accent.red
                ) {
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
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    AccountKeyRevokeView()
}
