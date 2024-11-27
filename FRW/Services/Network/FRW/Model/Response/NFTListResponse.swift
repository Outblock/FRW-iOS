//
//  NFTListResponse.swift
//  Flow Wallet
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation

// MARK: - NFTListResponse

struct NFTListResponse: Codable {
    let nfts: [NFTResponse]?
    let nftCount: Int
    let collection: NFTCollectionInfo?
}

extension NFTListResponse {
    func toCollectionItem() -> CollectionItem {
        let item = CollectionItem()
        item.name = collection?.name ?? ""
        item.count = nftCount
        item.nfts = nfts?.compactMap { NFTModel($0, in: collection) } ?? []
        item.collection = collection ?? NFTCollectionInfo(
            id: "",
            name: item.name,
            contractName: item.name,
            address: "",
            logo: "",
            banner: "",
            officialWebsite: "",
            description: "",
            path: ContractPath(
                storagePath: "",
                publicPath: "",
                privatePath: nil,
                publicCollectionName: "",
                publicType: "",
                privateType: ""
            ),
            evmAddress: nil,
            flowIdentifier: nil
        )
        item.isEnd = nftCount < 24
        return item
    }
}

// MARK: - NFTFavListResponse

struct NFTFavListResponse: Codable {
    let nfts: [NFTResponse]?
    let chain, network: String
    let nftcount: Int
}

// MARK: - NFTResponse

struct NFTResponse: Codable, Hashable {
    let id: String
    let name: String?
    let description: String?
    let thumbnail: String?
    let externalURL: String?
    let contractAddress: String?

    let evmAddress: String?
    let address: String?

    let collectionID: String?
    let collectionName: String?
    let collectionDescription: String?
    let collectionSquareImage: String?
    let collectionExternalURL: String?
    let collectionContractName: String?
    let collectionBannerImage: String?

    let traits: [NFTTrait]?
    var postMedia: NFTPostMedia?

    var flowIdentifier: String? = nil

    var uniqueId: String {
        (contractAddress ?? "") + "." + (collectionName ?? "") + "-" + "\(id)"
    }

    static func mock() -> NFTResponse {
        NFTResponse(
            id: "",
            name: "",
            description: "",
            thumbnail: "",
            externalURL: "",
            contractAddress: "",
            evmAddress: "",
            address: "",
            collectionID: "",
            collectionName: "",
            collectionDescription: "",
            collectionSquareImage: "",
            collectionExternalURL: "",
            collectionContractName: "",
            collectionBannerImage: "",
            traits: [],
            postMedia: NFTPostMedia(title: "", description: "", video: "", isSvg: false)
        )
    }

    func cover() -> String? {
        postMedia?.image ?? postMedia?.video ?? ""
    }

    func video() -> String? {
        postMedia?.video ?? ""
    }
}

// MARK: - NFTRoyalty

struct NFTRoyalty: Codable, Hashable {
    let cut: Double?
    let description: String?
}

// MARK: - NFTRoyaltyReceiver

struct NFTRoyaltyReceiver: Codable, Hashable {
    let address: String?
}

// MARK: - NFTRoyaltyReceiverPath

struct NFTRoyaltyReceiverPath: Codable, Hashable {
    let type: String?
    let value: NFTRoyaltyReceiverPathValue?
}

// MARK: - NFTRoyaltyReceiverPathValue

struct NFTRoyaltyReceiverPathValue: Codable, Hashable {
    let identifier: String?
    let domain: String?
}

// MARK: - NFTRoyaltyBorrowType

struct NFTRoyaltyBorrowType: Codable, Hashable {
    let kind: String?
    let authorized: Bool?
    let type: NFTRoyaltyBorrowTypeType?
}

// MARK: - NFTRoyaltyBorrowTypeType

struct NFTRoyaltyBorrowTypeType: Codable, Hashable {
    let typeID: String?
    let kind: String?
    let type: NFTRoyaltyBorrowTypeTypeType?
    let restrictions: [NFTRoyaltyBorrowTypeTypeType]?
}

// MARK: - NFTRoyaltyBorrowTypeTypeType

struct NFTRoyaltyBorrowTypeTypeType: Codable, Hashable {
    let typeID: String?
    let fields: [NFTRoyaltyBorrowTypeTypeTypeField]?
    let kind: String?
//    let type:
//    let initializers: []
}

// MARK: - NFTRoyaltyBorrowTypeTypeTypeField

struct NFTRoyaltyBorrowTypeTypeTypeField: Codable, Hashable {
    let id: String?
    let type: NFTRoyaltyBorrowTypeTypeTypeFieldType?
}

// MARK: - NFTRoyaltyBorrowTypeTypeTypeFieldType

struct NFTRoyaltyBorrowTypeTypeTypeFieldType: Codable, Hashable {
    let kind: String?
}

// MARK: - NFTPostMedia

struct NFTPostMedia: Codable, Hashable {
    let title: String?
    var image: String?
    let description: String?
    let video: String?
    let isSvg: Bool?
}

// MARK: - NFTTokenMetadata

struct NFTTokenMetadata: Codable, Hashable {
    let uuid: String
}

// MARK: - NFTTrait

struct NFTTrait: Codable, Hashable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String?.self, forKey: .name)
        displayType = try container.decode(String?.self, forKey: .displayType)
        do {
            value = try String(container.decode(Int.self, forKey: .value))
        } catch DecodingError.typeMismatch {
            do {
                value = try String(container.decode(Bool.self, forKey: .value))
            } catch DecodingError.typeMismatch {
                value = try container.decode(String?.self, forKey: .value)
            } catch {
                value = ""
            }
        } catch {
            value = ""
        }
    }

    // MARK: Internal

//    let rarity:

    enum CodingKeys: String, CodingKey {
        case name
        case value
        case displayType
    }

    let name: String?
    let value: String?
    let displayType: String?
}
