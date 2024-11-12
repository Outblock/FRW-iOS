//
//  FlowTransactionTemplate.swift
//  Flow Wallet
//
//  Created by Hao Fu on 14/9/2022.
//

import Foundation

// MARK: - FlowTransactionTemplate

struct FlowTransactionTemplate: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVersion = "f_version"
        case id, data
    }

    let fType, fVersion, id: String
    let data: FlowTransactionTemplateData

    static func == (lhs: FlowTransactionTemplate, rhs: FlowTransactionTemplate) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - FlowTransactionTemplateData

struct FlowTransactionTemplateData: Codable {
    let type, interface: String
    let messages: Messages?
    let cadence: String
//    let arguments: Arguments
}

// MARK: - Description

struct Description: Codable {
    enum CodingKeys: String, CodingKey {
        case i18N = "i18n"
    }

    let i18N: I18N?
}

// MARK: - I18N

struct I18N: Codable {
    enum CodingKeys: String, CodingKey {
        case enUS = "en-US"
    }

    let enUS: String?
}

// MARK: - Messages

struct Messages: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case messagesDescription = "description"
    }

    let title: Description?
    let messagesDescription: Description?
}
