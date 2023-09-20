//
//  AddressBookAddRequest.swift
//  Flow Reference Wallet
//
//  Created by Selina on 2/6/2022.
//

import Foundation

struct AddressBookAddRequest: Codable {
    let contactName: String
    let address: String
    let domain: String?
    let domainType: Contact.DomainType
    let username: String?
}

struct AddressBookEditRequest: Codable {
    let id: Int
    let contactName: String
    let address: String
    let domain: String?
    let domainType: Contact.DomainType
    let username: String?
}
