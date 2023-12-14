//
//  BackupPatternView.swift
//  FRW
//
//  Created by cat on 2023/12/8.
//

import SwiftUI

struct BackupPatternView: RouteableView {
    var title: String {
        return "backup".localized
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Color.clear
                .frame(width: 1, height: 24)
            BackupPatternItem(style: .device) { _ in
                onClickDeviceBackup()
            }
            BackupPatternItem(style: .multi) { _ in
                onClickMultiBackup()
            }
            Spacer()
        }
        .applyRouteable(self)
        .backgroundFill(Color.LL.Neutrals.background)
    }
    
    func onClickDeviceBackup() {
        
        
    }
    
    func onClickMultiBackup() {
        //TODO: 获取已备份的数据
        Router.route(to: RouteMap.Backup.multiBackup([]))
    }
}

struct BackupPatternItem: View {
    enum ItemStyle {
        case device
        case multi
    }
    
    var style: ItemStyle = .device
    var onClick: (ItemStyle) -> Void
    
    var body: some View {
        VStack {
            Image(iconName)
                .frame(width: 48, height: 48, alignment: .center)
                .padding(.top, 24)
                
            Text(title)
                .font(.inter(size: 20, weight: .bold))
                .foregroundStyle(color)
            Text(note)
                .font(.inter(size: 12))
                .multilineTextAlignment(.center)
                .foregroundStyle(color)
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
            
            Image("icon.arrow")
                .renderingMode(.template)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .padding(.bottom, 32)
        }
        
        .frame(width: screenWidth - 36)
        .background(color.fixedOpacity())
        .cornerRadius(24, style: .continuous)
        .padding(.horizontal, 18)
        .onTapGesture {
            onClick(style)
        }
    }
    
    var iconName: String {
        switch style {
        case .device:
            return "icon.device"
        case .multi:
            return "icon.multi"
        }
    }
    
    var title: String {
        switch style {
        case .device:
            return "create_device_backup_title".localized
        case .multi:
            return "create_multi_backup_title".localized
        }
    }
    
    var note: String {
        switch style {
        case .device:
            return "create_device_backup_note".localized
        case .multi:
            return "create_multi_backup_note".localized
        }
    }
    
    var color: Color {
        switch style {
        case .device:
            return Color.Theme.Accent.blue
        case .multi:
            return Color.Theme.Accent.purple
        }
    }
}

#Preview {
    BackupPatternView()
}
