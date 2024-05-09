//
//  SyncAccountViewModel.swift
//  FRW
//
//  Created by cat on 2023/11/24.
//

import UIKit
import WalletConnectPairing
import WalletConnectSign
import Combine

class SyncAccountViewModel: ObservableObject {
    @Published var uriString: String?
    @Published var isConnect: Bool = false
    private var publishers = [AnyCancellable]()
    
    private var topic: String?
    
    init() {
        Task {
            try await setupInitialState()
        }
        WalletConnectManager.shared.$setSessions
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { sessions in
                sessions.forEach { session in
                    if session.pairingTopic == self.topic {
                        self.isConnect = true
                    }
                }
                
            }.store(in: &publishers)
    }

    func setupInitialState() async throws {
        uriString = nil
        do {
            let uri = try await WalletConnectSyncDevice.createAndPair()
            WalletConnectManager.shared.prepareSyncAccount()
            
            log.info("[sync device] connect to topic: \(uri.absoluteString)")
            log.info("[sync device] connect to topic: \(uri)")
            DispatchQueue.main.async {
                self.topic = uri.topic
                self.uriString = uri.absoluteString
            }
        } catch {
            // TODO: handle error to UI
            log.error("[sync device] create uri error:\(error)")
        }
    }
}
