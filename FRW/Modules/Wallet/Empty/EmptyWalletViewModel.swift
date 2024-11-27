//
//  EmptyWalletViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 25/12/21.
//

import Alamofire
import Combine
import Foundation
import SwiftUI

// MARK: - EmptyWalletViewModel.Placeholder

extension EmptyWalletViewModel {
    struct Placeholder {
        let uid: String
        let avatar: String
        let username: String
        let address: String
    }
}

// MARK: - EmptyWalletViewModel

class EmptyWalletViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        UserManager.shared.$loginUIDList
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] list in
                guard let self = self else { return }
                var index = 1
                self.placeholders = list.map { uid in
                    let userInfo = MultiAccountStorage.shared.getUserInfo(uid)
                    var address = MultiAccountStorage.shared.getWalletInfo(uid)?
                        .getNetworkWalletModel(network: .mainnet)?.getAddress ?? "0x"
                    if address == "0x" {
                        address = LocalUserDefaults.shared.userAddressOfDeletedApp[uid] ?? "0x"
                    }
                    var username = userInfo?.username
                    if username == nil {
                        username = "Account \(index)"
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
    var placeholders: [EmptyWalletViewModel.Placeholder] = []

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

    func createNewAccountAction() {
        Router.route(to: RouteMap.Register.root(nil))
    }

    func loginAccountAction() {
        Router.route(to: RouteMap.RestoreLogin.restoreList)
    }

    func syncAccountAction() {
        Router.route(to: RouteMap.RestoreLogin.syncQC)
    }

    func tryToRestoreAccountWhenFirstLaunch() {
        if LocalUserDefaults.shared.tryToRestoreAccountFlag {
            // has been triggered or no old account to restore
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let isReachable = self.net?.isReachable else { return }

            if isReachable {
                self.net?.stopListening()
                UserManager.shared.tryToRestoreOldAccountOnFirstLaunch()
                return
            } else {
                self.net?.startListening(onQueue: .main, onUpdatePerforming: { status in
                    log.info("[NET] network changed")
                    switch status {
                    case .reachable:
                        self.tryToRestoreAccountWhenFirstLaunch()
                    default:
                        log.info("[NET] not reachable")
                    }
                })
            }
        }
    }

    // MARK: Private

    private var cancelSets = Set<AnyCancellable>()
    private var net: NetworkReachabilityManager? = NetworkReachabilityManager()
}
