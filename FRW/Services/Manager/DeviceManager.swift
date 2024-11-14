//
//  DeviceManager.swift
//  FRW
//
//  Created by cat on 2024/1/29.
//

import Flow
import Foundation

class DeviceManager: ObservableObject {
    // MARK: Internal

    static let shared = DeviceManager()

    func updateDevice() {
        Task {
            do {
                let uuid = UUIDManager.appUUID()
                let _: Network.EmptyResponse = try await Network
                    .request(FRWAPI.User.updateDevice(uuid))
            } catch {
                log.error("[Start] upload device")
            }
        }
    }

    func fetch() async throws -> (DeviceInfoModel?, [DeviceInfoModel]) {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            throw LLError.invalidAddress
        }
        let uuid = UUIDManager.appUUID()
        let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
        let list: [DeviceInfoModel] = try await Network.request(FRWAPI.User.devices(uuid))
        let keyResponse: KeyResponse = try await Network.request(FRWAPI.User.keys)
        let keyList = keyResponse.result ?? []

        // filter unrevoke key
        let validAccount = account.keys.filter { !$0.revoked }
        // filter valid key
        let validUserKeys = keyList.filter { keyModel in
            let result = validAccount
                .filter { $0.publicKey.description == keyModel.pubkey.publicKey }
            return !result.isEmpty
        }
        // filter device backup
        let validKeys = validUserKeys.filter { keyModel in
            if let type = keyModel.backupInfo?.type {
                return type < 0
            }
            return false
        }
        let filterList = list.filter { infoModel in
            let validDevices = validKeys.filter { deviceModel in
                deviceModel.device.id == infoModel.id
            }
            return !validDevices.isEmpty
        }

        var seenNames = Set<String>()
        var uniqueList = [DeviceInfoModel]()
        for info in filterList {
            if let id = info.id, !seenNames.contains(id) {
                uniqueList.append(info)
                seenNames.insert(id)
            }
        }

        let validDevices = filterList.filter { $0.id != uuid }
        let current = filterList.last { $0.id == uuid }

        validAccounts = validAccount
        self.validKeys = validKeys
        validDevice = uniqueList
        currentDevice = current

        return (current, validDevices)
    }

    func findFlowAccount(deviceId: String) -> Flow.AccountKey? {
        let key = findUserKey(deviceId: deviceId)
        guard let keyModel = key else {
            return nil
        }

        let accountKey = validAccounts.last { model in
            model.publicKey.description == keyModel.pubkey.publicKey
        }
        guard let accountKeyModel = accountKey else {
            return nil
        }

        return accountKeyModel
    }

    func findUserKey(deviceId: String) -> KeyDeviceModel? {
        let key = validKeys.last { model in
            model.device.id == deviceId
        }
        return key
    }

    func isCurrent(deviceId: String) -> Bool {
        if deviceId.isEmpty {
            return false
        }
        if let current = currentDevice {
            return deviceId == current.id
        }
        return false
    }

    // MARK: Private

    private var validAccounts: [Flow.AccountKey] = []
    private var validKeys: [KeyDeviceModel] = []
    private var validDevice: [DeviceInfoModel] = []
    private var currentDevice: DeviceInfoModel?
}
