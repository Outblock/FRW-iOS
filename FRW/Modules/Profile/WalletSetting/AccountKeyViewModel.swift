//
//  AccountKeyViewModel.swift
//  FRW
//
//  Created by cat on 2023/10/20.
//

import Flow
import SwiftUI

// MARK: - AccountKeyViewModel

class AccountKeyViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        addMock()
        fetch()
    }

    // MARK: Internal

    @Published
    var allKeys: [AccountKeyModel] = []
    @Published
    var status: PageStatus = .loading

    @Published
    var showRovekeView = false
    var revokeModel: AccountKeyModel?

    func addMock() {
        let model = Flow.AccountKey(
            publicKey: Flow.PublicKey(hex: "test"),
            signAlgo: .ECDSA_P256,
            hashAlgo: .SHA2_256,
            weight: 1000
        )
        allKeys = [AccountKeyModel(accountKey: model)]
    }

    func fetch() {
        Task {
            do {
                DispatchQueue.main.async {
                    self.status = .loading
                }
                let address = WalletManager.shared.getPrimaryWalletAddress() ?? ""
                let account = try await FlowNetwork.getAccountAtLatestBlock(address: address)
                let devices: KeyResponse = try await Network.request(FRWAPI.User.keys)
                DispatchQueue.main.async {
                    self.allKeys = account.keys.map { AccountKeyModel(accountKey: $0) }
                    self.allKeys = self.allKeys.map { model in
                        var model = model
                        let result = devices.result ?? []
                        let devicesInfo = result.first { response in
                            response.pubkey.publicKey == model.accountKey.publicKey.description
                        }
                        if let info = devicesInfo {
                            model.deviceType = DeviceType(value: info.device.deviceType)
                            if let backupInfo = info.backupInfo,
                               backupInfo.backupType() != .undefined {
                                model.backupType = backupInfo.backupType()
                                model.name = "backup".localized + " - " + backupInfo.backupType()
                                    .title
                            } else {
                                model.name = info.device.deviceName ?? ""
                            }
                        }
                        return model
                    }
                    self.status = self.allKeys.count == 0 ? .empty : .finished
                }

            } catch {
                allKeys = []
                status = .error
            }
        }
    }

    func revokeKey(at model: AccountKeyModel) {
        if showRovekeView {
            showRovekeView = false
        }
        revokeModel = model
        withAnimation(.easeOut(duration: 0.2)) {
            showRovekeView = true
        }
    }

    func revokeKeyAction() {
        Task {
            guard let model = self.revokeModel else {
                return
            }
            HUD.loading()
            let res = try await AccountKeyManager.revokeKey(at: model.accountKey.index)
            if res {
                DispatchQueue.main.async {
                    self.showRovekeView = false
                }
                fetch()
            }
            HUD.dismissLoading()
        }
    }

    func cancelRevoke() {
        DispatchQueue.main.async {
            self.revokeModel = nil
            self.showRovekeView = false
        }
    }
}

// MARK: - AccountKeyModel

struct AccountKeyModel {
    // MARK: Lifecycle

    init(accountKey: Flow.AccountKey) {
        self.accountKey = accountKey
    }

    // MARK: Internal

    enum ContentType: Int {
        case publicKey, curve, hash, number, weight, keyIndex
    }

    let accountKey: Flow.AccountKey
    var expanding: Bool = false
    var name: String = ""
    var backupType: BackupType = .undefined
    var deviceType: DeviceType = .iOS

    func deviceName() -> String {
        if backupType != .undefined {
            return "backup".localized + " - " + backupType.title
        }

        if isCurrent() {
            return "current_device".localized
        }
        if name.isEmpty {
            return "other_key".localized
        }
        return name
    }

    func deviceNameColor() -> Color {
        if isCurrent() {
            return Color.Theme.Accent.blue
        }

        return Color.Theme.Text.black3
    }

    func statusText() -> String {
        if accountKey.revoked {
            return "revoked".localized
        }
        if accountKey.weight >= 1000 {
            return "full_access".localized
        }
        return "multi_sign".localized
    }

    func statusColor() -> Color {
        if accountKey.revoked {
            return Color.Theme.Accent.red
        }
        if accountKey.weight >= 1000 {
            return Color.Theme.Accent.green
        }
        return Color.Theme.Text.black3
    }

    func isCurrent() -> Bool {
        guard let cur = WalletManager.shared.getCurrentPublicKey() else {
            return false
        }

        return cur == accountKey.publicKey.description
    }

    func titleIcon() -> String {
        if backupType != .undefined {
            return backupType.smallIcon
        }
        return deviceType.smallIcon
    }

    func icon(at type: ContentType) -> some View {
        Image("key.icon.\(type.rawValue)")
            .renderingMode(.template)
            .foregroundColor(Color.Theme.Text.black3)
    }

    func tag(at type: ContentType) -> String {
        switch type {
        case .publicKey:
            return "account_key_key".localized
        case .curve:
            return "account_key_curve".localized
        case .hash:
            return "account_key_hash".localized
        case .number:
            return "account_key_number".localized
        case .weight:
            return "account_key_weight".localized
        case .keyIndex:
            return "account_key_index".localized
        }
    }

    func content(at type: ContentType) -> String {
        switch type {
        case .publicKey:
            accountKey.publicKey.description
        case .curve:
            accountKey.signAlgo.rawValue
        case .hash:
            accountKey.hashAlgo.rawValue
        case .number:
            String(accountKey.sequenceNumber)
        case .weight:
            String(accountKey.weight)
        case .keyIndex:
            String(format: "%02d", accountKey.index)
        }
    }

    func weightDes() -> String {
        "\(accountKey.weight)/1000"
    }

    func weightPadding() -> Double {
        let res = Double(accountKey.weight) / 1000.0 * 72.0
        return min(72.0, res)
    }

    func weightBG() -> Color {
        Color.Theme.Background.silver
    }
}
