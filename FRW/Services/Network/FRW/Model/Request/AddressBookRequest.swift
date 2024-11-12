//
//  AddressBookRequest.swift
//  Flow Wallet
//
//  Created by Selina on 2/6/2022.
//

import Foundation

// MARK: - AddressBookAddRequest

struct AddressBookAddRequest: Codable {
    let contactName: String
    let address: String
    let domain: String?
    let domainType: Contact.DomainType
    let username: String?
}

// MARK: - AddressBookEditRequest

struct AddressBookEditRequest: Codable {
    let id: Int
    let contactName: String
    let address: String
    let domain: String?
    let domainType: Contact.DomainType
    let username: String?
}
