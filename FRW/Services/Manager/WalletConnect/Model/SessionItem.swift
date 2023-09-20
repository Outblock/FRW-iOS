//
//  Model.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 30/7/2022.
//

import Foundation

struct ActiveSessionItem: Identifiable, Equatable {
    let id = UUID()
    let dappName: String
    let dappURL: String
    let iconURL: String
    let topic: String
}
