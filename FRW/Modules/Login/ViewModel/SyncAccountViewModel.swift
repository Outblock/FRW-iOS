//
//  SyncAccountViewModel.swift
//  FRW
//
//  Created by cat on 2023/11/24.
//

import UIKit
import WalletConnectPairing
import WalletConnectSign

class SyncAccountViewModel: ObservableObject {
    @Published var uriString: String?

    init() {
        Task {
            try await setupInitialState()
        }
    }

    func setupInitialState() async throws {
        uriString = nil
        do {
            let uri = try await Pair.instance.create()
            
            try await Sign.instance.connect(requiredNamespaces: namespaces(), topic: uri.topic)
            WalletConnectManager.shared.prepareSyncAccount()
            log.info("[sync] uri: \(uri.absoluteString)")
            log.info("[sync] topic: \(uri.topic)")
            DispatchQueue.main.async {
                self.uriString = uri.absoluteString
            }
        } catch {
            print(error)
        }
    }

    func namespaces() -> [String: ProposalNamespace] {
        let methods: Set<String> = [FCLWalletConnectMethod.accountInfo.rawValue, FCLWalletConnectMethod.addDeviceInfo.rawValue]
        let namespaces = Sign.FlowWallet.namespaces(methods)
        return namespaces
    }
}
