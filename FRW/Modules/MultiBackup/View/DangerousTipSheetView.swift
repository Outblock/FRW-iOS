//
//  DangerousTipSheetView.swift
//  FRW
//
//  Created by cat on 2024/1/9.
//

import SwiftUI

struct DangerousTipSheetView: View {
    let title: String
    let detail: String
    let buttonTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack {
            SheetHeaderView(title: title) {
                onCancel()
            }

            VStack(spacing: 0) {
                Text(detail)
                    .font(.inter(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Theme.Accent.red)
                Image("icon_key_revoke")
                    .frame(width: 64, height: 64)
                    .padding(.top, 24)

                Spacer()

                WalletSendButtonView(
                    allowEnable: .constant(true),
                    buttonText: buttonTitle,
                    activeColor: Color.Theme.Accent.red
                ) {
                    onConfirm()
                }
                .padding(.bottom, 10)
                Button {
                    onCancel()
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
    DangerousTipSheetView(
        title: "account_key_revoke_title".localized,
        detail: "account_key_revoke_content".localized,
        buttonTitle: "hold_to_revoke".localized
    ) {} onCancel: {}
}
