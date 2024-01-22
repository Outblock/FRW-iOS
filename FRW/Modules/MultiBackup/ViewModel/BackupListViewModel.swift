//
//  BackupListViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/6.
//

import Flow
import SwiftUI

class BackupListViewModel: ObservableObject {
//    @Published var muiltList: [BackupListViewModel.Item] = []
    @Published var isLoading = true
    
    @Published var backupList: [KeyDeviceModel] = []
    @Published var deviceList: [DeviceInfoModel] = []
    @Published var showCurrent: Bool = false
    @Published var showOther: Bool = false
    @Published var current: DeviceInfoModel?
    @Published var showAllUITag = true
    @Published var showAllDevices = false
    @Published var showDevicesCount = 0
    
    @Published var showRemoveTipView = false
    var removeIndex: Int?
    
    private let showCount = 2
    
    init() {}
    
    func fetchData() {
        Task {
            DispatchQueue.main.async{
                self.isLoading = true
            }
            await fetchDeviceBackup()
            await fetchMultiBackup()
            
            DispatchQueue.main.async{
                self.isLoading = false
            }
        }
    }
    
    func onDelete(index: Int) {
        if showRemoveTipView {
            showRemoveTipView = false
        }
        
        removeIndex = index
        withAnimation(.easeOut(duration: 0.2)) {
            showRemoveTipView = true
        }
    }
    
    func onCancelTip() {
        showRemoveTipView = false
    }
    
    func removeMultiBackup() {
        guard let index = removeIndex, backupList.count > index else { return }
        let item = backupList[index]
        guard let type = item.multiBackupType(), let keyIndex = item.backupInfo?.keyIndex else { return }
        if keyIndex == 0 {
            log.error("[Flow] don't revoke key at index 0")
            return
        }
        Task {
            HUD.loading()
            await revokeKey(at: keyIndex)
            try await MultiBackupManager.shared.removeItem(with: type)
            await fetchMultiBackup()
            showRemoveTipView = false
            HUD.dismissLoading()
        }
    }
    
    private func revokeKey(at index: Int) async {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            HUD.info(title: "account_key_fail_tips".localized)
            return
        }
        do {
            let flowId = try await FlowNetwork.revokeAccountKey(by: index, at: Flow.Address(hex: address))
            log.debug("revoke flow id:\(flowId)")
            
        } catch {
            HUD.error(title: "account_key_fail_tips".localized)
            log.error("revoke key: \(error)")
        }
    }
}

extension BackupListViewModel {
    var showAllTagTitle: String {
        return showAllDevices ? "view_all".localized : "hide".localized
    }
    
    func fetchDeviceBackup() async {
        do {
            let list: [DeviceInfoModel] = try await Network.request(FRWAPI.User.devices(UUIDManager.appUUID()))
            DispatchQueue.main.async {
                self.deviceList = list.filter { model in
                    model.id != UUIDManager.appUUID()
                }
                self.current = list.filter { model in
                    model.id == UUIDManager.appUUID()
                }.first
                self.showCurrent = (self.current != nil)
                self.showOther = self.deviceList.count > 0
                self.showAllDevices = false
                self.showAllUITag = self.deviceList.count > self.showCount
                self.showDevicesCount = min(self.showCount, self.deviceList.count)
            }
        } catch {
            DispatchQueue.main.async {
                self.deviceList = []
                self.current = nil
                self.showCurrent = false
            }
            log.error("Fetch Devices \(error)")
        }
    }
    
    func onShowAllDevices() {
        showAllDevices.toggle()
        showDevicesCount = showAllDevices ? deviceList.count : min(showCount, deviceList.count)
    }
}

extension BackupListViewModel {
    func fetchMultiBackup() async {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            HUD.error(title: "invalid_address".localized)
            return
        }
        do {
            let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
            let devices: KeyResponse = try await Network.request(FRWAPI.User.keys)
            let deviceList = devices.result ?? []
            
            let allBackupList = deviceList.filter { model in
                if model.pubkey.weight >= 1000 {
                    return false
                }
                if let info = model.backupInfo {
                    return info.type != .undefined
                }
                return false
            }
            
            let validBackupList = allBackupList.filter { model in
                
                let flowAccount = account.keys.first { accountkey in
                    model.pubkey.publicKey == accountkey.publicKey.description
                }
                if let flowAccount = flowAccount {
                    return !flowAccount.revoked
                }
                return false
            }
            let fixBackupList = validBackupList.map { model in
                var item = model
                let flowAccount = account.keys.first { accountkey in
                    model.pubkey.publicKey == accountkey.publicKey.description
                }
                item.backupInfo?.keyIndex = flowAccount?.index
                return item
            }
            DispatchQueue.main.async {
                self.backupList = fixBackupList
            }
            
        } catch {
            log.error("[backup] fetch multi \(error.localizedDescription)")
        }
    }
    
//    func fetchMultiBackup() async {
//        guard let uid = UserManager.shared.activatedUID, !uid.isEmpty else {
//            return
//        }
//        var currentUserList: [BackupListViewModel.Item] = []
//        for type in MultiBackupType.allCases {
//            do {
//                let list = try await MultiBackupManager.shared.getCloudDriveItems(from: type)
//                let current = list.filter { $0.userId == uid }.first
//                if let current = current {
//                    let item = BackupListViewModel.Item(store: current, backupType: type)
//                    currentUserList.append(item)
//                }
//            } catch {}
//        }
//        let list = currentUserList
//        DispatchQueue.main.async {
//            self.muiltList = []
//            self.muiltList.append(contentsOf: list)
//        }
//    }
    
    func currentMultiBackup() -> [MultiBackupType] {
        return backupList.compactMap { $0.multiBackupType() }
    }
}

extension KeyDeviceModel {
    func multiBackupType() -> MultiBackupType? {
        switch backupInfo?.type {
        case .google:
            return MultiBackupType.google
        case .iCloud:
            return MultiBackupType.icloud
        case .manual:
            return MultiBackupType.phrase
        case .passkey:
            return MultiBackupType.passkey
        default:
            return nil
        }
    }
}

// extension BackupListViewModel {
//    struct Item {
//        let store: MultiBackupManager.StoreItem
//        let backupType: MultiBackupType
//    }
// }
