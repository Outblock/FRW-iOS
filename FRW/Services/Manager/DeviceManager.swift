//
//  DeviceManager.swift
//  FRW
//
//  Created by cat on 2024/1/29.
//

import Foundation
import Flow

class DeviceManager: ObservableObject {
    static let shared = DeviceManager()
    
    private var validAccounts: [Flow.AccountKey] = []
    private var validKeys: [KeyDeviceModel] = []
    private var validDevice: [DeviceInfoModel] = []
    private var currentDevice: DeviceInfoModel?
    
    func fetch() async throws -> (DeviceInfoModel?, [DeviceInfoModel]) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let uuid = UUIDManager.appUUID()
        let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
        let list: [DeviceInfoModel] = try await Network.request(FRWAPI.User.devices(uuid))
        let keyResponse: KeyResponse = try await Network.request(FRWAPI.User.keys)
        let keyList = keyResponse.result ?? []
        
        let validAccount = account.keys.filter { !$0.revoked }
        let validKeys = keyList.filter { keyModel in
            let result = validAccount.filter { $0.publicKey.description == keyModel.pubkey.publicKey }
            return result.count > 0
        }
        let filterList = list.filter { infoModel in
            let validDevices = validKeys.filter { deviceModel in
                deviceModel.device.id == infoModel.id
            }
            return validDevices.count > 0
        }
        
        let validDevices = filterList.filter { $0.id != uuid }
        let current = filterList.first { $0.id == uuid }
        
        self.validAccounts = validAccount
        self.validKeys = validKeys
        self.validDevice = filterList
        self.currentDevice = current
        
        return (current, validDevices)
    }
    
    func findFlowAccount(deviceId: String) -> Flow.AccountKey? {
        let key = self.validKeys.first { model in
            model.device.id == deviceId
        }
        guard let keyModel = key else {
            return nil
        }
        
        let accountKey = self.validAccounts.first { model in
            model.publicKey.description == keyModel.pubkey.publicKey
        }
        guard let accountKeyModel = accountKey else {
            return nil
        }
        
        return accountKeyModel
    }
    
    func isCurrent(deviceId: String) -> Bool {
        if deviceId.isEmpty {
            return false
        }
        if let current = self.currentDevice {
            return deviceId == current.id
        }
        return false
    }
    
}
