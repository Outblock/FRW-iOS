//
//  BackupListViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/6.
//

import SwiftUI

class BackupListViewModel: ObservableObject {
    
    @Published var muiltList: [String] = []
    @Published var isLoading = true
    
    @Published var deviceList: [DeviceInfoModel] = []
    @Published var showCurrent: Bool = false
    @Published var showOther: Bool = false
    @Published var current: DeviceInfoModel?
    @Published var showAllUITag = true
    @Published var showAllDevices = false
    @Published var showDevicesCount = 0
    
    private let showCount = 2
    
    init() {
        Task {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            await fetchDeviceBackup()
            await fetchMuiltBackup()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    func fetchMuiltBackup() async {
        
    }
}

extension BackupListViewModel {
    
    var showAllTagTitle: String {
        return self.showAllDevices ? "view_all".localized : "hide".localized
    }
    
    func fetchDeviceBackup() async {
        do {
            let list: [DeviceInfoModel] = try await Network.request(FRWAPI.User.devices(UUIDManager.appUUID()))
            DispatchQueue.main.async {
                self.deviceList = list.filter({ model in
                    model.id != UUIDManager.appUUID()
                })
                self.current = list.filter({ model in
                    model.id == UUIDManager.appUUID()
                }).first
                self.showCurrent = (self.current != nil)
                self.showOther = self.deviceList.count > 0
                self.showAllDevices = false
                self.showAllUITag = self.deviceList.count > self.showCount
                self.showDevicesCount = min(self.showCount, self.deviceList.count)
                
            }
        }
        catch {
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
        showDevicesCount = showAllDevices ? deviceList.count : min(self.showCount, self.deviceList.count)
    }
    
}
