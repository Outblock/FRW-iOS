//
//  FRWAPI+EVM.swift
//  FRW
//
//  Created by cat on 2024/4/29.
//

import Foundation
import Moya

extension FRWAPI {
    enum EVM {
        case tokenList(String?)
        case nfts(String?)
    }
}

extension FRWAPI.EVM: TargetType, AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var baseURL: URL {
        switch self {
        case .tokenList, .nfts:
            return Config.get(.lilicoWeb)
        }
    }
    
    var path: String {
        switch self {
        case .tokenList(let addr):
            if let addr = addr {
                return "evm/\(addr)/fts"
            }
            return "evm/fts"
        case .nfts(let addr):
            if let addr = addr {
                return "evm/\(addr)/nfts"
            }
            return "evm/nfts"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        switch self {
        case .tokenList, .nfts:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        let headers = FRWAPI.commonHeaders
        return headers
    }
}
