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
            let uri = try await WalletConnectSyncDevice.createAndPair()
            WalletConnectManager.shared.prepareSyncAccount()
            log.info("[sync device] connect to topic: \(uri)")
            DispatchQueue.main.async {
                self.uriString = uri.absoluteString
            }
        } catch {
            // TODO: handle error to UI
            log.error("[sync device] create uri error:\(error)")
        }
    }
}
