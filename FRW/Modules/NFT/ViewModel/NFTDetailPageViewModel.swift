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
    let showSendButton: Bool
    
    @Published var isPresentMove = false
    
    let animationView = AnimationView(name: "inAR", bundle: .main)
    
    init(nft: NFTModel) {
        self.nft = nft
        showSendButton = RemoteConfigManager.shared.config?.features.nftTransfer ?? false
        if nft.isSVG {
            guard let rawSVGURL = nft.response.postMedia.image,
                  let rawSVGURL = URL(string: rawSVGURL.replacingOccurrences(of: "https://lilico.app/api/svg2png?url=", with: "")) else {
                return
            }
            
            Task {
                if let svg = await SVGCache.cache.getSVG(rawSVGURL) {
                    DispatchQueue.main.async {
                        self.svgString = svg
                    }
                } else {
                    DispatchQueue.main.async {
                        self.nft.isSVG = false
                        self.nft.response.postMedia.image = self.nft.response.postMedia.image?.convertedSVGURL()?.absoluteString
                    }
                }
            }
        }
        fetchNFTStatus()
    }
    
    func sendNFTAction() {
        Router.route(to: RouteMap.AddressBook.pick({ [weak self] contact in
            Router.dismiss(animated: true) {
                guard let self = self else {
                    return
                }
                Router.route(to: RouteMap.NFT.send(self.nft, contact))
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
        
        
        Task {
            let address = self.nft.response.contractAddress ?? ""
            let evmAddress = await NFTCollectionConfig.share.get(from: address)?.evmAddress
            if evmAddress == nil && self.nft.collection?.flowIdentifier == nil {
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
}
