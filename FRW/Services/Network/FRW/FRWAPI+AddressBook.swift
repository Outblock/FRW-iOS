//
//  Flow Reference WalletAPI+AddressBook.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 19/5/2022.
//

import Foundation
import Moya

extension FRWAPI {
    enum AddressBook {
        case addExternal(AddressBookAddRequest)
        case fetchList
        case delete(Int)
        case edit(AddressBookEditRequest)
    }
}

extension FRWAPI.AddressBook: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }

    var baseURL: URL {
        return Config.get(.lilico)
    }

    var path: String {
        switch self {
        case .addExternal:
            return "/v1/addressbook/external"
        case .fetchList, .delete, .edit:
            return "/v1/addressbook/contact"
        }
    }

    var method: Moya.Method {
        switch self {
        case .addExternal:
            return .put
        case .fetchList:
            return .get
        case .delete:
            return .delete
        case .edit:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .fetchList:
            return .requestPlain
        case let .addExternal(request):
            return .requestCustomJSONEncodable(request, encoder: FRWAPI.jsonEncoder)
        case let .delete(contactId):
            return .requestParameters(parameters: ["id": contactId], encoding: URLEncoding.queryString)
        case let .edit(request):
            return .requestCustomJSONEncodable(request, encoder: FRWAPI.jsonEncoder)
        }
    }

    var headers: [String: String]? {
        return FRWAPI.commonHeaders
    }
}
