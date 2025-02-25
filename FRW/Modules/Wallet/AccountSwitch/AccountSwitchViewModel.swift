//
//  AccountSwitchViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 13/6/2023.
//

import Combine
import SwiftUI

// MARK: - AccountSwitchViewModel.Placeholder

extension AccountSwitchViewModel {
    struct Placeholder {
        let uid: String
        let avatar: String
        let username: String
        let address: String
    }
}

// MARK: - AccountSwitchViewModel

class AccountSwitchViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        UserManager.shared.$loginUIDList
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] list in
                guard let self = self else { return }
                var index = 1
                let userStoreList = LocalUserDefaults.shared.userList
                self.placeholders = list.map { uid in
                    let userInfo = MultiAccountStorage.shared.getUserInfo(uid)
                    var address = MultiAccountStorage.shared.getWalletInfo(uid)?
                        .getNetworkWalletModel(network: .mainnet)?.getAddress ?? "0x"
                    if address == "0x" {
                        address = LocalUserDefaults.shared.userAddressOfDeletedApp[uid] ?? "0x"
                    }
                    if address == "0x" {
                        let userStore = userStoreList.last { $0.userId == uid }
                        address = userStore?.address ?? "0x"
                    }
                    var username = userInfo?.nickname
                    if username == nil {
                        username = "Profile \(index)"
                        index += 1
                    }
                    return Placeholder(
                        uid: uid,
                        avatar: userInfo?.avatar ?? "",
                        username: username ?? "",
                        address: address
                    )
                }
            }.store(in: &cancelSets)
    }

    // MARK: Internal

    @Published
    var placeholders: [Placeholder] = []
    var selectedUid: String?

    func createNewAccountAction() {
        Router.route(to: RouteMap.Register.root(nil))
    }

    func loginAccountAction() {
        Router.route(to: RouteMap.RestoreLogin.restoreList)
    }

    func switchAccountAction(_ uid: String) {
        Task {
            do {
                HUD.loading()
                try await UserManager.shared.switchAccount(withUID: uid)
                HUD.dismissLoading()
            } catch {
                log.error("switch account failed", context: error)
                HUD.dismissLoading()
                HUD.error(title: error.localizedDescription)
            }
        }
    }

    // MARK: Private

    private var cancelSets = Set<AnyCancellable>()
}
