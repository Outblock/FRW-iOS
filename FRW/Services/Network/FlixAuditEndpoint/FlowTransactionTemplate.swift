//
//  FlowTransactionTemplate.swift
//  Flow Wallet
//
//  Created by Hao Fu on 14/9/2022.
//

import Foundation

// MARK: - FlowTransactionTemplate

struct FlowTransactionTemplate: Codable, Equatable {
    let fType, fVersion, id: String
    let data: FlowTransactionTemplateData

    enum CodingKeys: String, CodingKey {
        case fType = "f_type"
        case fVersion = "f_version"
        case id, data
    }

    static func == (lhs: FlowTransactionTemplate, rhs: FlowTransactionTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - DataClass

struct FlowTransactionTemplateData: Codable {
    let type, interface: String
    let messages: Messages?
    let cadence: String
//    let arguments: Arguments
}

// MARK: - Description

struct Description: Codable {
    let i18N: I18N?

    enum CodingKeys: String, CodingKey {
        case i18N = "i18n"
    }
}

// MARK: - I18N

struct I18N: Codable {
    let enUS: String?

    enum CodingKeys: String, CodingKey {
        case enUS = "en-US"
    }
}

// MARK: - DataMessages

struct Messages: Codable {
    let title: Description?
    let messagesDescription: Description?

    enum CodingKeys: String, CodingKey {
        case title
        case messagesDescription = "description"
    }
}
