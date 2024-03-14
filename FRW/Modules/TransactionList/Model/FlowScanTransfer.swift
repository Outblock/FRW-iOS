//
//  FlowScanTransfer.swift
//  Flow Wallet
//
//  Created by Selina on 9/9/2022.
//

import UIKit
import SwiftUI

extension FlowScanTransfer {
    enum TransferType: Int, Codable {
        case unknown = 0
        case send = 1
        case receive = 2
    }
}

struct FlowScanTransfer: Codable {
    let additional_message: String?
    let amount: String?
    let error: Bool?
    let image: String?
    let receiver: String?
    let sender: String?
    let status: String?
    let time: String?
    let title: String?
    let token: String?
    let transferType: FlowScanTransfer.TransferType?
    let txid: String?
    let type: Int?
    
    var statusColor: UIColor {
        if status != "Sealed" {
            return UIColor.LL.Neutrals.text3
        }
        
        if let error = error, error == true {
            return UIColor.LL.Warning.warning2
        } else {
            return UIColor.LL.Success.success3
        }
    }
    
    var swiftUIStatusColor: Color {
        if status != "Sealed" {
            return Color.LL.Neutrals.text3
        }
        
        if let error = error, error == true {
            return Color.LL.Warning.warning2
        } else {
            return Color.LL.Success.success3
        }
    }
    
    var statusText: String {
        if status?.lowercased() != "Sealed".lowercased() {
            return "transaction_pending".localized
        }
        
        if let error = error, error == true {
            return "transaction_error".localized
        } else {
            return status ?? "transaction_pending".localized
        }
    }
    
    var transferDesc: String {
        var dateString = ""
        if let time = time, let df = ISO8601Formatter.date(from: time) {
            dateString = df.mmmddString
        }
        
        var targetStr = ""
        if self.transferType == TransferType.send {
            targetStr = "transfer_to_x".localized(self.receiver ?? "")
        } else if self.sender != nil {
            targetStr = "transfer_from_x".localized(self.sender ?? "")
        }
        
        return "\(dateString) \(targetStr)"
    }
    
    var amountString: String {
        if let amountString = self.amount, !amountString.isEmpty {
            return amountString
        } else {
            return "-"
        }
    }
}
