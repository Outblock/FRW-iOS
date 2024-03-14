//
//  NFTRequests.swift
//  Flow Wallet
//
//  Created by Selina on 9/8/2022.
//

import Foundation

struct NFTGridDetailListRequest: Codable {
    var address: String = "0x050aa60ac445a061"
    var offset: Int = 0
    var limit: Int = 24
}

struct NFTCollectionDetailListRequest: Codable {
    var address: String = "0x050aa60ac445a061"
    var collectionIdentifier: String
    var offset: Int = 0
    var limit: Int = 24
}

struct NFTAddFavRequest: Codable {
    var address: String = "0x050aa60ac445a061"
    var contract: String
    var ids: String
}

struct NFTUpdateFavRequest: Codable {
    var ids: String
}
