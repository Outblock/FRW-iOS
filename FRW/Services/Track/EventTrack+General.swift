//
//  EventTrack+General.swift
//  FRW
//
//  Created by cat on 10/22/24.
//

import Foundation

extension EventTrack.General {
    enum RampSource: String {
        case coinbase
        case moonpay
    }
    static func rpcError(error: String, scriptId: String) {
        EventTrack.send(event: EventTrack.General.rpcError, properties: [
            "error": error,
            "script_id": scriptId,
        ])
    }

    static func delegationCreated(
        address: String,
        nodeId: String,
        amount: Double
    ) {
        EventTrack
            .send(event: EventTrack.General.delegationCreated, properties: [
                "address": address,
                "node_id": nodeId,
                "amount": amount,
            ])
    }

    ///  BuyProvderView button action
    static func rampClick(source: RampSource) {
        EventTrack
            .send(event: EventTrack.General.rampClicked, properties: [
                "source": source.rawValue,
            ])
    }

    static func coaCreation(txId: String, flowAddress: String, message: String) {
        EventTrack
            .send(event: EventTrack.General.coaCreation, properties: [
                "tx_id": txId,
                "flow_address": flowAddress,
                "error_message": message,
            ])
    }

    static func security(type: SecurityManager.SecurityType) {
        EventTrack
            .send(event: EventTrack.General.securityTool, properties: [
                "type": type.trackLabel(),
            ])
    }
}

extension SecurityManager.SecurityType {
    func trackLabel() -> String {
        switch self {
        case .none:
            "none"
        case .pin:
            "pin"
        case .bionic:
            "biometric"
        case .both:
            "both"
        }
    }
}
