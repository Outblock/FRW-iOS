//
//  AlchemyEndpoint.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Moya

struct NFTListRequest: Codable {
    var owner: String = "0x050aa60ac445a061"
    var offset: Int = 0
    var limit: Int = 100
}

enum AlchemyEndpoint {
    case nftList(NFTListRequest)
}

extension AlchemyEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "https://flow-mainnet.g.alchemy.com/v2/twx0ea5rbnqjbg7ev8jb058pqg50wklj/")!
    }

    var path: String {
        switch self {
        case .nftList:
            return "getNFTs/"
        }
    }

    var method: Moya.Method {
        .get
    }

    var task: Task {
        switch self {
        case let .nftList(nftListRequest):
            return .requestParameters(parameters: nftListRequest.dictionary ?? [:], encoding: URLEncoding())
        }
    }

    var headers: [String: String]? {
        nil
    }
}

extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
    
    func jsonPrettyPrinted() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw FCLError.decodeFailure
        }
        return string
    }
}
