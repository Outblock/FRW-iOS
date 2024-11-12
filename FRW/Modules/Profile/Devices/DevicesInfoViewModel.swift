//
//  DevicesInfoViewModel.swift
//  FRW
//
//  Created by cat on 2024/3/12.
//

import Flow
import SwiftUI

// MARK: - DevicesInfoViewModel

class DevicesInfoViewModel: ObservableObject {
    // MARK: Lifecycle

    init(model: DeviceInfoModel) {
        self.model = model
        if let deviceId = self.model.id {
            accountKey = DeviceManager.shared.findFlowAccount(deviceId: deviceId)
            userKey = DeviceManager.shared.findUserKey(deviceId: deviceId)
            let localKey = WalletManager.shared.getCurrentPublicKey()
            if DeviceManager.shared.isCurrent(deviceId: deviceId) {
                showRevokeButton = false
            } else if accountKey != nil {
                if localKey == accountKey?.publicKey.description {
                    showRevokeButton = false
                } else {
                    showRevokeButton = true
                }
            } else {
                showRevokeButton = false
            }
        } else {
            showRevokeButton = false
        }
    }

    // MARK: Internal

    @Published
    var showRemoveTipView = false
    @Published
    var showRevokeButton = false
    var model: DeviceInfoModel
    var accountKey: Flow.AccountKey?
    var userKey: KeyDeviceModel?

    func onRevoke() {
        if showRemoveTipView {
            showRemoveTipView = false
        }
        withAnimation(.easeOut(duration: 0.2)) {
            showRemoveTipView = true
        }
    }

    func onCancel() {
        showRemoveTipView = false
    }

    func revokeAction() {
        guard let deviceId = model.id else {
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }
        let isCurrent = DeviceManager.shared.isCurrent(deviceId: deviceId)
        guard !isCurrent else {
            HUD.info(title: "account_key_current_tips".localized)
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }

        guard let accountKey = DeviceManager.shared.findFlowAccount(deviceId: deviceId) else {
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }
        guard let cur = WalletManager.shared.getCurrentPublicKey(),
              cur != accountKey.publicKey.description
        else {
            HUD.info(title: "account_key_current_tips".localized)
            withAnimation(.easeOut(duration: 0.2)) {
                showRemoveTipView = false
                showRevokeButton = false
            }
            return
        }

        Task {
            HUD.loading()
            let res = try await AccountKeyManager.revokeKey(at: accountKey.index)
            if res {
                withAnimation(.easeOut(duration: 0.2)) {
                    showRemoveTipView = false
                    showRevokeButton = false
                }
                Router.pop()
                HUD.dismissLoading()
            }
        }
    }
}

extension DevicesInfoViewModel {
    var keyIcon: String {
        let deviceType = DeviceType(value: userKey?.device.deviceType ?? 1)
        return deviceType.smallIcon
    }

    var showKeyTitle: String {
        if isCurrent {
            return "current_device".localized
        }
        return model.deviceName ?? ""
    }

    var showKeyTitleColor: Color {
        isCurrent ? Color.Theme.Accent.blue : Color.Theme.Text.black3
    }

    var isCurrent: Bool {
        DeviceManager.shared.isCurrent(deviceId: model.id ?? "")
    }
}
