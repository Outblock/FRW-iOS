//
//  NFTSquareCard.swift
//  Lilico
//
//  Created by cat on 2022/5/16.
//

import Kingfisher
import SwiftUI

struct NFTSquareCard: View {
    var nft: NFTModel
    var imageEffect: Namespace.ID
    var onClick: (NFTModel) -> Void

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                KFImage
                    .url(nft.imageURL)
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.width, alignment: .center)
                    .cornerRadius(8)
                    .matchedGeometryEffect(id: nft.id, in: imageEffect)
                    .clipped()
                Text(nft.title)
                    .font(.LL.body)
                    .semibold()
                    .lineLimit(1)

                Text(nft.subtitle)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
                    .lineLimit(1)
            }
        }
        .onTapGesture {
            onClick(nft)
        }
    }
}

struct NFTSquareCard_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        NFTSquareCard(nft: NFTTabViewModel.testNFT(), imageEffect: namespace, onClick: { _ in

        })
        .frame(width: 160)
    }
}
