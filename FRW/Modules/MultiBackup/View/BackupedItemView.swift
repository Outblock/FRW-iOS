//
//  BackupedItemView.swift
//  FRW
//
//  Created by cat on 2024/8/9.
//

import SwiftUI

struct BackupedItemView: View {
    
    let backupType: MultiBackupType
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(backupType.iconName())
                    .resizable()
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(backupType.title) Backup")
                        .font(.inter(size: 16))
                        .foregroundStyle(Color.Theme.Text.black8)
                        .foregroundColor(.black.opacity(0.8))
                    Text(showApp())
                        .font(.inter(size: 12))
                        .foregroundStyle(Color.Theme.Text.black3)
                    Text(showLocation())
                        .font(.inter(size: 12))
                        .foregroundStyle(Color.Theme.Text.black3)
                }
                Spacer()
                HStack {
                    Image("check_fill_1")
                        .frame(width: 16, height: 16)
                }
                .frame(width: 16)
                .frame(minHeight: 0, maxHeight: .infinity)
            }
            .padding(16)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 96)
            
            VStack {
                Divider()
                    .background(Color.Theme.Line.line)
                    .frame(height: 1)
                
                
            }
        }
        .background(.Theme.Background.grey)
        .cornerRadius(16)
        
    }
    
    private func showApp() -> String {
        let item = MultiBackupManager.shared.getTarget(with: backupType)
        return item.registeredDeviceInfo?.deviceInfo.showApp() ?? ""
    }
    
    private func showLocation() -> String {
        let item = MultiBackupManager.shared.getTarget(with: backupType)
        return item.registeredDeviceInfo?.deviceInfo.showLocation() ?? ""
    }
}

#Preview {
    BackupedItemView(backupType: .google)
}
