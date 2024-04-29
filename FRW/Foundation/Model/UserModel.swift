//
//  UserModel.swift
//  Flow Wallet
//
//  Created by Selina on 7/6/2022.
//

import SwiftUI

struct UserInfo: Codable {
    let avatar: String
    let nickname: String
    let username: String
    let `private`: Int?
    var type: UserManager.UserType?
    
    /// Only applicable under certain circumstances.
    /// Note: The Logged-in user did not use this.
    let address: String?

    var isPrivate: Bool {
        return self.private == 2
    }
    
    var meowDomain: String {
        return "\(username).\(Contact.DomainType.meow.domain)"
    }
    
    var meowDomainHost: String {
        return username
    }
    
    func toContact() -> Contact {
        let contact = Contact(address: address, avatar: avatar, contactName: nickname, contactType: .user, domain: nil, id: UUID().hashValue, username: username)
        return contact
    }
    
    func toContactWithCurrentUserAddress() -> Contact {
        let contact = Contact(address: WalletManager.shared.getPrimaryWalletAddress(), avatar: avatar, contactName: nickname, contactType: .user, domain: nil, id: UUID().hashValue, username: username)
        return contact
    }
}
