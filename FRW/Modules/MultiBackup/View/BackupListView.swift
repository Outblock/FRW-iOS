//
//  BackupPatternView.swift
//  FRW
//
//  Created by cat on 2023/12/8.
//

import SwiftUI

struct BackupListView: RouteableView {
    @StateObject var viewModel = BackupListViewModel()
    
    var title: String {
        return "backup".localized
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                Color.clear
                    .frame(width: 1, height: 24)
                BackupPatternItem(style: .device) { _ in
                    onClickDeviceBackup()
                }
                .visibility(viewModel.hasDeviceBackup ? .gone : .visible)
                .mockPlaceholder(viewModel.isLoading)
                
                BackupPatternItem(style: .multi) { _ in
                    onClickMultiBackup()
                }
                .visibility(viewModel.hasMultiBackup ? .gone : .visible)
                .mockPlaceholder(viewModel.isLoading)
                
                Divider()
                    .foregroundStyle(.clear)
                    .background(Color.Theme.Line.line)
                    .visibility((viewModel.hasDeviceBackup && viewModel.hasMultiBackup) ? .gone : .visible)
                
                deviceListView
                    .visibility(viewModel.hasDeviceBackup ? .visible : .gone)
                
                multiListView
                    .visibility(viewModel.hasMultiBackup ? .visible : .gone)
                
                Spacer()
            }
            .padding(.horizontal, 18)
        }
        .applyRouteable(self)
        .backgroundFill(Color.LL.Neutrals.background)
        .halfSheet(showSheet: $viewModel.showRemoveTipView) {
            DangerousTipSheetView(title: "account_key_revoke_title".localized, 
                                  detail: "account_key_revoke_content".localized,
                                  buttonTitle: "hold_to_revoke".localized) {
                viewModel.removeMultiBackup()
            } onCancel: {
                viewModel.onCancelTip()
            }
        }
        .navigationBarItems(trailing: HStack(spacing: 6) {
            if isDevModel {
                Button {
                    MultiBackupManager.shared.clearCloud()
                } label: {
                    Image(systemName: "xmark.circle")
                        .renderingMode(.template)
                        .foregroundColor(.LL.Primary.salmonPrimary)
                }
            }
            
        })
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    var deviceListView: some View {
        VStack {
            HStack {
                Text("device_backup".localized)
                    .font(.inter(size: 16, weight: .semibold))
                    .foregroundStyle(Color.Theme.Text.black8)
                Spacer()
                Button {
                    onAddDevice()
                } label: {
                    Image("icon-wallet-coin-add")
                        .renderingMode(.template)
                        .foregroundColor(.LL.Neutrals.neutrals1)
                }
            }
            .padding(.top, 24)
            
            if viewModel.current != nil {
                DevicesView.Cell(model: viewModel.current!, isCurrent: true)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("other_device".localized)
                        .font(.inter(size: 14, weight: .bold))
                        .foregroundColor(Color.Theme.Text.black3)
                    Spacer()
                    Button {
                        onShowAll()
                    } label: {
                        Text("view_all".localized)
                            .font(.inter(size: 14, weight: .bold))
                            .foregroundStyle(Color.Theme.Text.black3)
                    }
                    .visibility(viewModel.showAllUITag ? .visible : .gone)
                }
                
                ForEach(0..<viewModel.showDevicesCount, id: \.self) { index in
                    DevicesView.Cell(model: viewModel.deviceList[index])
                }
            }
            .padding(.top, 24)
            .visibility(viewModel.showOther ? .visible : .gone)
        }
    }
    
    var multiListView: some View {
        VStack {
            HStack {
                Text("multi_backup".localized)
                    .font(.inter(size: 16, weight: .semibold))
                    .foregroundStyle(Color.Theme.Text.black8)
                Spacer()
                Button {
                    onAddMulti()
                } label: {
                    Image("icon-wallet-coin-add")
                        .renderingMode(.template)
                        .foregroundColor(.LL.Neutrals.neutrals1)
                }
            }
            .padding(.top, 24)
            
            ForEach(0..<viewModel.backupList.count, id: \.self) { index in
                let item = viewModel.backupList[index]
                BackupListView.BackupFinishItem(item: item, index: index) { _, deleteIndex in
                    viewModel.onDelete(index: deleteIndex)
                }
            }
        }
    }
    
    func onAddDevice() {
        Router.route(to: RouteMap.Profile.devices)
    }
    
    func onShowAll() {
        viewModel.onShowAllDevices()
    }
    
    func onClickDeviceBackup() {
        viewModel.onShowDeviceBackup()
    }
    
    func onClickMultiBackup() {
        viewModel.onShowMultiBackup()
    }
    
    func onAddMulti() {
        viewModel.onAddMultiBackup()
    }
}

// MARK: Create Backup View

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
            
            Image("icon.arrow")
                .renderingMode(.template)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .padding(.bottom, 32)
                .padding(.top, 24)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(color.fixedOpacity())
        .cornerRadius(24, style: .continuous)
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

// MARK: Finished Item View of Multi-Backup

extension BackupListView {
    struct BackupFinishItem: View {
        var item: KeyDeviceModel
        var index: Int
        var onDelete: (MultiBackupType, Int) -> Void
        
        var body: some View {
            Button {
                Router.route(to: RouteMap.Backup.backupDetail(item))
            } label: {
                HStack(alignment: .top) {
                    Image(item.multiBackupType()?.iconName() ?? "")
                        .resizable()
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(item.multiBackupType()?.title ?? "") Backup")
                            .font(.inter(size: 16))
                            .foregroundStyle(Color.Theme.Text.black8)
                            .foregroundColor(.black.opacity(0.8))
                        Text(item.device.showApp())
                            .font(.inter(size: 12))
                            .foregroundStyle(Color.Theme.Text.black3)
                        Text(item.device.showLocation())
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
                .background(.Theme.Background.grey)
                .cornerRadius(16)
                .onViewSwipe(title: "delete".localized) {
                    onDelete(item.multiBackupType()!, index)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
        }
    }
}

#Preview {
    BackupListView()
}
