//
//  FlowScanTransaction.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import Foundation
import SwiftUI
import UIKit

extension FlowScanTransaction {
    struct Account: Codable {
        let address: String?
    }

    struct ContractInteraction: Codable {
        let identifier: String?
    }
}

struct FlowScanTransaction: Codable {
    let authorizers: [FlowScanTransaction.Account]?
    let contractInteractions: [ContractInteraction]?
    let error: String?
    let eventCount: Int?
    let hash: String?
    let index: Int?
    let payer: FlowScanTransaction.Account?
    let proposer: FlowScanTransaction.Account?
    let status: String?
    let time: String?

    var statusColor: UIColor {
        if status != "Sealed" {
            return UIColor.LL.Neutrals.text3
        }

        if let error = error, !error.isEmpty {
            return UIColor.LL.Warning.warning2
        } else {
            return UIColor.LL.Success.success3
        }
    }

    var statusText: String {
        if status != "Sealed" {
            return "transaction_pending".localized
        }

        if let error = error, !error.isEmpty {
            return "transaction_error".localized
        } else {
            return status ?? "transaction_pending".localized
        }
    }

    var transactionDesc: String {
        var dateString = ""
        if let time = time, let df = ISO8601Formatter.date(from: time) {
            dateString = df.mmmddString
        }

        var interactions = [String]()
        if let contractInteractions = contractInteractions {
            for interaction in contractInteractions {
                if let id = interaction.identifier {
                    interactions.append(id)
                }
            }
        }

        let contractInteractionsString = interactions.joined(separator: " ")

        if contractInteractionsString.isEmpty {
            return "\(dateString)"
        } else {
            return "\(dateString) · \(contractInteractionsString)"
        }
    }
}
