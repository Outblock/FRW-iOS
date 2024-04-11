//
//  BackupTipsView.swift
//  Flow Wallet
//
//  Created by Selina on 6/6/2023.
//

import SwiftUI

struct BackupTipsView: View {
    var closeAction: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: "backup".localized) {
                onCloseAction()
            }
            
            contentView
        }
        .backgroundFill(Color.LL.Neutrals.background)
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            Text("backup_tips_desc".localized)
                .font(.inter(size: 14))
                .foregroundColor(Color.LL.Neutrals.text2)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Image("backup-tips-safe-img")
            
            Spacer()
            
            Button {
                onBackupAction()
            } label: {
                Text("start".localized)
                    .font(.inter(size: 17, weight: .semibold))
                    .foregroundColor(Color.LL.frontColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.LL.rebackground)
                    .cornerRadius(14)
            }
            .padding(.bottom, 20)
            
            Button {
                onCloseAction()
            } label: {
                Text("not_now".localized)
                    .font(.inter(size: 17, weight: .regular))
                    .foregroundColor(Color.LL.Neutrals.text2)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
    }
}

extension BackupTipsView {
    private func onCloseAction() {
        closeAction()
    }
    
    private func onBackupAction() {
        onCloseAction()
        Router.route(to: RouteMap.Backup.backupList)
    }
}
