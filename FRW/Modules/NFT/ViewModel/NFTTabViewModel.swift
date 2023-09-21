//
//  NFTTabViewModel.swift
//  Flow Reference Wallet
//
//  Created by Hao Fu on 16/1/22.
//

import Foundation
import Haneke
import Kingfisher

import SwiftUIX

extension NFTTabScreen {
    enum ViewStyle {
        case normal
        case grid
        
        var desc: String {
            switch self {
            case .normal:
                return "List"
            case .grid:
                return "Grid"
            default:
                return ""
            }
        }
    }
    
    struct ViewState {
        var colorsMap: [String: [Color]] = [:]
    }

    enum Action {
        case search
        case info(NFTModel, Bool)
        case fetchColors(String)
        case back
    }
}

class NFTTabViewModel: ViewModel {
    @Published var state: NFTTabScreen.ViewState = .init()

    /*
     0x2b06c41f44a05656
     0xccea80173b51e028
     0x53f389d96fb4ce5e
     0x01d63aa89238a559
     0x050aa60ac445a061
     0xadca05d078ebf98a
     */
//    private var owner: String = "0x95601dba5c2506eb"

    init() {
        
    }

    func trigger(_ input: NFTTabScreen.Action) {
        switch input {
        case let .info(model,fromLinkedAccount):
            Router.route(to: RouteMap.NFT.detail(self, model, fromLinkedAccount))
        case .search:
            break
        case let .fetchColors(url):
            fetchColors(from: url)
        case .back:
            Router.pop()
        }
    }
}

extension NFTTabViewModel {
    func fetchColors(from url: String) {
        if state.colorsMap[url] != nil {
            return
        }
        Task {
            let colors = await ImageHelper.colors(from: url)
            DispatchQueue.main.async {
                self.state.colorsMap[url] = colors
            }
        }
    }
}

@propertyWrapper
struct NullEncodable<T>: Encodable where T: Encodable {
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch wrappedValue {
        case let .some(value): try container.encode(value)
        case .none: try container.encodeNil()
        }
    }
}

extension NFTTabViewModel {
    static func testCollection() -> CollectionItem {
        let nftModel = testNFT()
        let model = CollectionItem()
        return model
    }

    static func testNFT() -> NFTModel {
        let nftJsonData = """
        {
                        "contract": {
                            "address": "0x2d2750f240198f91",
                            "contractMetadata": {
                                "publicCollectionName": "MatrixWorldFlowFestNFT.MatrixWorldFlowFestNFTCollectionPublic",
                                "publicPath": "MatrixWorldFlowFestNFT.CollectionPublicPath",
                                "storagePath": "MatrixWorldFlowFestNFT.CollectionStoragePath"
                            },
                            "externalDomain": "matrixworld.org",
                            "name": "MatrixWorldFlowFestNFT"
                        },
                        "description": "a patrol code block for interacting with objects, 930/1500",
                        "externalDomainViewUrl": "matrixworld.org",
                        "id": {
                            "tokenId": "929",
                            "tokenMetadata": {
                                "uuid": "60564528"
                            }
                        },
                        "media": [
                            {
                                "mimeType": "image",
                                "uri": "https://storageapi.fleek.co/124376c1-1582-4135-9fbb-f462a4f1403c-bucket/logo-10.png"
                            }
                        ],
                        "metadata": {
                            "metadata": [
                                {
                                    "name": "type",
                                    "value": "common"
                                },
                                {
                                    "name": "hash",
                                    "value": ""
                                }
                            ]
                        },
                        "postMedia": {
                            "description": "a patrol code block for interacting with objects, 930/1500",
                            "image": "https://storageapi.fleek.co/124376c1-1582-4135-9fbb-f462a4f1403c-bucket/logo-10.png",
                            "title": "Patrol Code Block"
                        },
                        "title": "Patrol Code Block"
                    }
        """.data(using: .utf8)!

        let collJsonData = """
        {
        "name": "OVO",
        "address": {
        "mainnet": "0x75e0b6de94eb05d0",
        "testnet": "0xacf3dfa413e00f9f"
        },
        "path": {
        "storage_path": "NyatheesOVO.CollectionStoragePath",
        "public_path": "NyatheesOVO.CollectionPublicPath",
        "public_collection_name": "NyatheesOVO.NFTCollectionPublic"
        },
        "contract_name": "NyatheesOVO",
        "logo": "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovologo.jpeg",
        "banner": "https://raw.githubusercontent.com/Outblock/assets/main/nft/nyatheesovo/ovobanner.png",
        "official_website": "https://www.ovo.space/#/",
        "marketplace": "https://www.ovo.space/#/Market",
        "description": "ovo (ovo space) is the industry's frst platform to issue holographic AR-NFT assets and is currently deployed on the BSC and FLOW. The NFT issued by ovo will be delivered as Super Avatars to various Metaverses and GameFi platforms."
        }
        """.data(using: .utf8)!

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try! jsonDecoder.decode(NFTResponse.self, from: nftJsonData)
        let collModel = try! jsonDecoder.decode(NFTCollectionInfo.self, from: collJsonData)
        return NFTModel(response, in: collModel)
    }
}
