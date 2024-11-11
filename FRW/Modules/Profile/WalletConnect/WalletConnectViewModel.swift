//
//  ProfileBackupViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 2/8/2022.
//

import Combine
import SwiftUI
import WalletConnectSign

// MARK: - WalletConnectViewModel

class WalletConnectViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        WalletConnectManager.shared.reloadPendingRequests()
    }

    // MARK: Private

    private var cancelSets = Set<AnyCancellable>()
}

extension WalletConnectSign.Request {
    var logoURL: URL? {
        if let session = WalletConnectManager.shared.activeSessions
            .first(where: { $0.topic == self.topic }), let logoString = session.peer.icons.first {
            return URL(string: logoString)
        }

        return nil
    }

    var name: String? {
        if let session = WalletConnectManager.shared.activeSessions
            .first(where: { $0.topic == self.topic }) {
            return session.peer.name
        }

        return nil
    }

    var dappURL: URL? {
        if let session = WalletConnectManager.shared.activeSessions
            .first(where: { $0.topic == self.topic }) {
            return URL(string: session.peer.url)
        }

        return nil
    }
}
