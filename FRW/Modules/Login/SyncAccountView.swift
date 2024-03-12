//
//  SyncAccount.swift
//  FRW
//
//  Created by cat on 2023/11/24.
//

import SwiftUI

struct SyncAccountView: RouteableView {
    @ObservedObject var viewModel: SyncAccountViewModel = .init()
    
    var title: String {
        "sync_flow_reference".localized
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 9) {
                Text("sync_top_hint".localized)
                    .multilineTextAlignment(.center)
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundStyle(Color.Theme.Text.black8)
                QRCodeView(content: viewModel.uriString ?? "")
                    .padding(.top, 32)
                Text("sync_qr_code_mobile".localized)
                    .font(.inter(size: 16, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
                    .padding(.top, 16)
                
                Color.clear
                    .frame(width: 1, height: 40)
                
                Text("sync_qr_code_mobile_note".localized)
                    .multilineTextAlignment(.center)
                    .font(.inter(size: 14))
                    .foregroundStyle(Color.Theme.Accent.grey)
            }
            .padding(.horizontal, 28)
        }
        .applyRouteable(self)
    }
}

#Preview {
    SyncAccountView()
}
