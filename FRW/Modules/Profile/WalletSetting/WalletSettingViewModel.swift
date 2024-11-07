//
//  WalletSettingViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 24/10/2022.
//

import Flow
import SwiftUI

class WalletSettingViewModel: ObservableObject {
    @Published var storageUsagePercent: Double = 0
    @Published var storageUsageDesc: String = ""

    init() {
        fetchStorageInfo()
    }

    private func fetchStorageInfo() {
        Task {
            do {
                let info = try await FlowNetwork.checkStorageInfo()
                DispatchQueue.main.async {
                    self.storageUsagePercent = info.usedPercent
                    self.storageUsageDesc = info.usedString
                }
            } catch {}
        }
    }

    func resetWalletAction() {
        Router.route(to: RouteMap.Profile.resetWalletConfirm)
    }
}

extension Flow.StorageInfo {
    var usedPercent: Double {
        if capacity <= 0 {
            return 0
        }

        return min(1, max(0, Double(used) / Double(capacity)))
    }

    var usedString: String {
        let usedStr = humanReadableByteCount(bytes: used)
        let capacityStr = humanReadableByteCount(bytes: capacity)
        return "\(usedStr) / \(capacityStr)"
    }

    private func humanReadableByteCount(bytes: UInt64) -> String {
        if bytes < 1024 { return "\(bytes) B" }
        let exp = Int(log2(Double(bytes)) / log2(1024.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1024, Double(exp))
        if exp <= 1 || number >= 100 {
            return String(format: "%.0f %@", number, unit)
        } else {
            return String(format: "%.1f %@", number, unit)
                .replacingOccurrences(of: ".0", with: "")
        }
    }
}
