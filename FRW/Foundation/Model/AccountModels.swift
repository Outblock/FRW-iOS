//
//  AccountModels.swift
//  FRW
//
//  Created by Antonio Bello on 11/7/24.
//

import Flow
import Foundation

extension Flow {
    struct AccountInfo: Decodable {
        public let address: Flow.Address
        public let balance: Decimal
        public let availableBalance: Decimal
        public let storageUsed: UInt64
        public let storageCapacity: UInt64
        public let storageFlow: Decimal
    }
}

extension Flow.AccountInfo {
    var storageUsedRatio: Double {
        guard storageCapacity > 0 else { return 0 }
        let ratio = Double(storageUsed) / Double(storageCapacity)
        return min(1, max(0, ratio))
    }

    var storageUsedString: String {
        let usedStr = humanReadableByteCount(bytes: storageUsed)
        let capacityStr = humanReadableByteCount(bytes: storageCapacity)
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
