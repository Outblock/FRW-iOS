//
//  Flow WalletAPI+NFT.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/14.
//

import Foundation
import Moya

extension FRWAPI {
    typealias Address = String

    struct Offset {
        static var `default`: FRWAPI.Offset {
            Offset(start: 0, length: 24)
        }

        let start: Int
        let length: Int

        func next() -> FRWAPI.Offset {
            Offset(start: start + length, length: length)
        }
    }
}

extension FRWAPI {
    enum From {
        case main
        case evm
    }

    enum NFT {
        case collections
        case userCollection(String, FRWAPI.Offset, FRWAPI.From)
        case collectionDetailList(NFTCollectionDetailListRequest, FRWAPI.From)
        case gridDetailList(NFTGridDetailListRequest, FRWAPI.From)
        case favList(String)
        case addFav(NFTAddFavRequest)
        case updateFav(NFTUpdateFavRequest)
    }
}

// MARK: - FRWAPI.NFT + TargetType, AccessTokenAuthorizable

extension FRWAPI.NFT: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        .bearer
    }

    var baseURL: URL {
        switch self {
        case .favList, .addFav, .updateFav:
            return Config.get(.lilico)
        default:
            #if LILICOPROD
                return URL(string: "https://lilico.app/api/")!
            #else
                return URL(string: "https://test.lilico.app/api/")!
            #endif
        }
    }

    var path: String {
        switch self {
        case let .gridDetailList(_, from):
            if from == .evm {
                return "v3/evm/nft/list"
            }
            return "v2/nft/list"
        case let .userCollection(_, _, from):
            if from == .evm {
                return "v3/evm/nft/id"
            }
            return "v2/nft/id"
        case .collections:
            return "v2/nft/collections"
        case let .collectionDetailList(_, from):
            if from == .evm {
                return "v3/evm/nft/collectionList"
            }
            return "v2/nft/collectionList"
        case .addFav, .updateFav:
            return "v2/nft/favorite"
        case .favList:
            return "v3/nft/favorite"
        }
    }

    var method: Moya.Method {
        switch self {
        case .collections, .collectionDetailList, .gridDetailList, .favList, .userCollection:
            return .get
        case .addFav:
            return .put
        case .updateFav:
            return .post
        }
    }

    var task: Task {
        switch self {
        case let .gridDetailList(request, _):
            return .requestParameters(
                parameters: request.dictionary ?? [:],
                encoding: URLEncoding()
            )
        case let .collectionDetailList(request, _):
            return .requestParameters(
                parameters: request.dictionary ?? [:],
                encoding: URLEncoding()
            )
        case .collections:
            return .requestParameters(parameters: [:], encoding: URLEncoding())
        case let .favList(address):
            return .requestParameters(parameters: ["address": address], encoding: URLEncoding())
        case let .addFav(request):
            return .requestJSONEncodable(request)
        case let .updateFav(request):
            return .requestJSONEncodable(request)
        case let .userCollection(address, offset, _):
            return .requestParameters(
                parameters: ["address": address, "offset": offset.start, "limit": offset.length],
                encoding: URLEncoding()
            )
        }
    }

    var headers: [String: String]? {
        let headers = FRWAPI.commonHeaders
        return headers
    }
}
