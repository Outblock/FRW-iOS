//
//  NFTFavoriteView.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/19.
//

import CollectionViewPagingLayout
import Kingfisher
import SwiftUI

struct NFTFavoriteView: View {
    @Binding var favoriteId: String?

    var favoriteNFTs: [NFTModel]
    var onClick: () -> Void

    var body: some View {
        VStack {
            if favoriteNFTs.count > 0 {
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("top_selection".localized)
                            .font(.LL.largeTitle2)
                            .semibold()

                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top)
                    .foregroundColor(.white)

                    StackPageView(favoriteNFTs, selection: $favoriteId) { nft in
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.LL.background)

                            KFImage
                                .url(nft.imageURL)
                                .placeholder({
                                    Image("placeholder")
                                        .resizable()
                                })
                                .fade(duration: 0.25)
                                .resizable()
                                .aspectRatio(1, contentMode: .fill)
                                .cornerRadius(8)
                                .padding()
                        }
                        .onTapGesture {
                            onTapNFT()
                        }
                    }
                    .options(options)
                    .pagePadding(
                        top: .absolute(18),
                        left: .absolute(18),
                        bottom: .absolute(18),
                        right: .fractionalWidth(0.22)
                    )
                    .frame(width: screenWidth,
                           height: screenHeight * 0.4, alignment: .center)
                }
                .background(LinearGradient(colors: [.clear, .LL.background],
                                           startPoint: .top, endPoint: .bottom))
            }
        }
    }

    var options = StackTransformViewOptions(
        scaleFactor: 0.10,
        minScale: 0.20,
        maxScale: 0.95,
        maxStackSize: 6,
        spacingFactor: 0.1,
        maxSpacing: nil,
        alphaFactor: 0.00,
        bottomStackAlphaSpeedFactor: 0.90,
        topStackAlphaSpeedFactor: 0.30,
        perspectiveRatio: 0.30,
        shadowEnabled: true,
        shadowColor: Color.LL.rebackground.toUIColor()!,
        shadowOpacity: 0.10,
        shadowOffset: .zero,
        shadowRadius: 5.00,
        stackRotateAngel: 0.00,
        popAngle: 0.31,
        popOffsetRatio: .init(width: -1.45, height: 0.30),
        stackPosition: .init(x: 1.00, y: 0.00),
        reverse: false,
        blurEffectEnabled: false,
        maxBlurEffectRadius: 0.00,
        blurEffectStyle: .light
    )

    func onTapNFT() {
        onClick()
    }
}

struct NFTFavoriteView_Previews: PreviewProvider {
    @State static var list: [NFTModel] = []
    @State static var favoriteId: String?
    static var previews: some View {
        NFTFavoriteView(favoriteId: $favoriteId, favoriteNFTs: list) {}
    }
}
