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
            
            if backupType == .phrase {
                VStack {
                    
                    Divider()
                        .background(Color.Theme.Line.line)
                        .frame(height: 1)
                        .padding(.horizontal, 18)
                    
                    HStack {
                        Spacer()
                        WordListView(data: Array(mnemonicList().prefix(8)))
                        Spacer()
                        WordListView(data: Array(mnemonicList().suffix(from: 8)))
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 30)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Button {
                            UIPasteboard.general.string = mnemonic()
                            HUD.success(title: "copied".localized)
                        } label: {
                            Image("icon-copy-phrase")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(Color.Theme.Accent.green)
                                .frame(width: 100,height: 40)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 10) {
                        Text("not_share_secret_tips".localized)
                            .font(.LL.caption)
                            .bold()
                        Text("not_share_secret_desc".localized)
                            .font(.LL.footnote)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 24)
                    .foregroundColor(.LL.warning2)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundColor(.LL.warning6)
                    }
                    .padding(.horizontal,10)
                    .padding(.top)
                    .padding(.bottom)
                }
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
    
    private func mnemonic() -> String? {
        
        guard let mnemonic = MultiBackupManager.shared.mnemonic else {
//            #if DEBUG
//            let str = "timber bulk peace tree cannon vault tomorrow case violin decade bread song song song song"
//            return str
//            #endif
            return nil
        }
        if backupType != .phrase {
            return nil
        }
        return mnemonic
    }
    
    private func mnemonicList() -> [WordListView.WordItem] {
        guard let mnemonic = mnemonic() else {
            return []
        }
        
        let list = mnemonic.split(separator: " ").enumerated().map { item in
            WordListView.WordItem(id: item.offset + 1, word: String(item.element))
        }
        return list
    }
    
    
}

#Preview {
    BackupedItemView(backupType: .google)
}
