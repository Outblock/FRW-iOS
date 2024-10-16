//
//  CreateDeviceBackupView.swift
//  FRW
//
//  Created by cat on 2024/1/9.
//

import SwiftUI

struct CreateDeviceBackupView: RouteableView {
    var title: String {
        return "create_device_backup_title".localized
    }

    var body: some View {
        VStack(spacing: 0) {
            Image("device.icon.create")
                .resizable()
                .frame(width: 48, height: 48)
            Text("scan_to_extension".localized)
                .font(.inter(size: 16, weight: .semibold))
                .lineSpacing(24)
                .foregroundStyle(Color.Theme.Text.black3)

            Text("scan_to_extension_detail".localized)
                .font(.inter(size: 12))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.Theme.Text.black8)

            Button {
                // TODO:
            } label: {
                ZStack {
                    HStack(spacing: 8) {
                        Image("wallet-sync-icon")
                            .frame(width: 24, height: 24)

                        Text("sync_wallet".localized)
                            .font(.inter(size: 17, weight: .bold))
                            .foregroundColor(Color(hex: "#333333"))
                    }
                }
                .frame(height: 58)
                .frame(maxWidth: .infinity)
                .background(.white)
                .contentShape(Rectangle())
                .cornerRadius(29)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.black, lineWidth: 1.5)
                )
            }
        }
    }
}

#Preview {
    CreateDeviceBackupView()
}
