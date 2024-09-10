//
//  NFTDetailPageViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 6/9/2022.
//

import Foundation
import Kingfisher
import SwiftUI
import Lottie

class NFTDetailPageViewModel: ObservableObject {
    @Published var nft: NFTModel
    @Published var svgString: String = ""
    @Published var movable: Bool = false
    @Published var showSendButton: Bool = false
    
    @Published var isPresentMove = false
    
    let animationView = AnimationView(name: "inAR", bundle: .main)
    
    init(nft: NFTModel) {
        self.nft = nft
        if nft.isSVG {
            guard let rawSVGURL = nft.response.postMedia?.image,
                  let rawSVGURL = URL(string: rawSVGURL.replacingOccurrences(of: "https://lilico.app/api/svg2png?url=", with: "")) else {
                return
            }
            
            Task {
                if let svg = await SVGCache.cache.getSVG(rawSVGURL) {
                    DispatchQueue.main.async {
                        self.svgString = svg
                    }
                } else if let data = nft.imageData, let svg = decodeBase64ToString(data) {
                    DispatchQueue.main.async {
                        self.svgString = svg
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.nft.isSVG = false
                        self.nft.response.postMedia?.image = self.nft.response.postMedia?.image?.convertedSVGURL()?.absoluteString
                    }
                }
            }
        }
        updateCollectionIfNeed()
        fetchNFTStatus()
        updateSendButton()
    }
    
    func decodeBase64ToString(_ base64String: String) -> String? {
        // 清理 Base64 字符串，去除无效字符和空白字符
        let cleanedBase64String = base64String
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^A-Za-z0-9+/=]", with: "", options: .regularExpression)

        // 计算所需的填充字符数量（如果需要）
        let requiredPadding = cleanedBase64String.count % 4
        let paddingLength = (4 - requiredPadding) % 4
        let paddedBase64String = cleanedBase64String + String(repeating: "=", count: paddingLength)

        // 尝试将 Base64 字符串解码为 Data
        if let data = Data(base64Encoded: paddedBase64String) {
            // 使用指定的字符编码（例如 UTF-8）将 Data 转换回字符串
            return String(data: data, encoding: .utf8)
        } else {
            // 解码失败，返回 nil
            return nil
        }
    }
    
    func sendNFTAction(fromChildAccount: ChildAccount? = nil) {
        Router.route(to: RouteMap.AddressBook.pick({ [weak self] contact in
            Router.dismiss(animated: true) {
                guard let self = self else {
                    return
                }
                Router.route(to: RouteMap.NFT.send(self.nft, contact, fromChildAccount))
            }
        }))
    }
    
    func image() async -> UIImage {
        guard let image = await ImageHelper.image(from: nft.imageURL.absoluteString) else {
            return UIImage(imageLiteralResourceName: "placeholder")
        }
        
        return image
    }
    
    func showMoveAction() {
        isPresentMove = true
    }
    
    func fetchNFTStatus() {
        if self.nft.isDomain {
            movable = false
            return
        }
        if ChildAccountManager.shared.childAccounts.count > 0 {
            movable = true
            return
        }
        
        Task {
            let address = self.nft.response.contractAddress ?? ""
            let evmAddress = await NFTCollectionConfig.share.get(from: address)?.evmAddress
            let hasEvm = EVMAccountManager.shared.accounts.count > 0
            if evmAddress == nil || self.nft.collection?.flowIdentifier == nil || !hasEvm {
                DispatchQueue.main.async {
                    self.movable = false
                }
                
                return
            }
            DispatchQueue.main.async {
                withAnimation {
                    self.movable = true
                }
            }
        }
    }
    
    private func updateSendButton() {
        let remote = RemoteConfigManager.shared.config?.features.nftTransfer ?? false
        if remote == true {
            if nft.isDomain {
                showSendButton = false
            }else {
                showSendButton = true
            }
        }else {
            showSendButton = false
        }
        
    }
    
    private func updateCollectionIfNeed() {
        guard let contractAddress = nft.response.contractAddress else {
            return
        }
        Task {
            let nftCollection = await NFTCollectionConfig.share.get(from: contractAddress)
            if self.nft.collection == nil {
                self.nft.collection = nftCollection
            }
        }
    }
}
