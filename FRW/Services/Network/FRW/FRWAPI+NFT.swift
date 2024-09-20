//
//  Flow WalletAPI+NFT.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/14.
//

import Foundation
import Moya

extension FRWAPI {
    enum NFT {
        case collections
        case userCollection(String,Int,Int)
        case collectionDetailList(NFTCollectionDetailListRequest)
        case gridDetailList(NFTGridDetailListRequest)
        case favList(String)
        case addFav(NFTAddFavRequest)
        case updateFav(NFTUpdateFavRequest)
    }
}

extension FRWAPI.NFT: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
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
        case .gridDetailList:
            return "v2/nft/list"
        case .userCollection:
            return "v2/nft/id"
        case .collections:
            return "v2/nft/collections"
        case .collectionDetailList:
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
        case let .gridDetailList(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case let .collectionDetailList(request):
            return .requestParameters(parameters: request.dictionary ?? [:], encoding: URLEncoding())
        case .collections:
            return .requestParameters(parameters: [:], encoding: URLEncoding())
        case let .favList(address):
            return .requestParameters(parameters: ["address": address], encoding: URLEncoding())
        case let .addFav(request):
            return .requestJSONEncodable(request)
        case let .updateFav(request):
            return .requestJSONEncodable(request)
        case let .userCollection(address,offset,limit):
            return .requestParameters(parameters: ["address": address,"offset": offset,"limit": limit], encoding: URLEncoding())
        }
    }

    var headers: [String: String]? {
        let headers = FRWAPI.commonHeaders

//        #if DEBUG
//            // TODO: current nft is error on testnet, remove this code if testnet nft is working someday.
//            headers["Network"] = LocalUserDefaults.FlowNetworkType.mainnet.rawValue
//        #endif
        return headers
    }
}
