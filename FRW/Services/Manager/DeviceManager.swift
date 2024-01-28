//
//  DeviceManager.swift
//  FRW
//
//  Created by cat on 2024/1/29.
//

import Foundation

class DeviceManager: ObservableObject {
    static let shared = DeviceManager()
    
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
//        let result = validAccount.filter { accountKey in
//            let key = keyList.first { $0.pubkey.publicKey == accountKey.publicKey.description }
//            let deviceInfo = list.first { $0.id == key?.device.id }
//            if deviceInfo != nil {
//                return true
//            }
//            return false
//        }
        
        let filterList = list.filter { infoModel in
            let keys = keyList.filter { keyModel in
                keyModel.device.id == infoModel.id
            }
            let accounts = keys.filter { keyModel in
                let result = validAccount.filter { $0.publicKey.description == keyModel.pubkey.publicKey }
                return result.count > 0
            }
            return accounts.count > 0
        }
        
        
        let validDevices = filterList.filter { $0.id != uuid }
        let current = filterList.first { $0.id == uuid }
        
        
        return (current, validDevices)
    }
}
