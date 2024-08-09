//
//  EVMAssetProvider.swift
//  FRW
//
//  Created by cat on 2024/5/21.
//

import Foundation

protocol NFTMask {
    
    var maskLogo: String { get }
    var maskId: String { get }
}

protocol CollectionMask {
    var maskAddress: String { get }
    var maskName: String { get }
    var maskContractName: String { get }
    var maskLogo: URL? { get }
    var maskId: String { get }
    var maskCount: Int { get }
}

// MARK: NFTResponse
extension NFTResponse: NFTMask {
    var maskLogo: String {
        return cover() ?? thumbnail ?? ""
    }
    
    var maskId: String {
        return id
    }
}

// MARK: NFTCollection
extension NFTCollection: CollectionMask {
    var maskName: String {
        collection.name
    }
    
    var maskAddress: String {
        collection.address
    }
    
    var maskContractName: String {
        collection.contractName
    }
    
    var maskId: String {
        collection.id
    }
    
    var maskLogo: URL? {
        collection.logoURL
    }
    
    var maskCount: Int {
        return count
    }
    
}

// MARK: EVMNFT
extension EVMNFT: NFTMask {
    var maskLogo: String {
        return thumbnail
    }
    
    var maskId: String {
        id
    }
}

// MARK: EVMCollection
extension EVMCollection: CollectionMask {
    var maskAddress: String {
        guard let addr = flowIdentifier?.split(separator: ".")[1] else {
            return ""
        }
        return String(addr).addHexPrefix()
    }
    
    var maskName: String {
        name
    }
    
    var maskContractName: String {
        guard let name = flowIdentifier?.split(separator: ".")[2] else {
            return ""
        }
        return String(name)
    }
    
    var maskLogo: URL? {
        URL(string: logoURI)
    }
    
    var maskId: String {
        ""
    }
    
    var maskCount: Int {
        nfts.count
    }
    
    
}
