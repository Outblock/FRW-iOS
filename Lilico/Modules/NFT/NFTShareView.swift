//
//  NFTShareView.swift
//  Flow Reference Wallet
//
//  Created by cat on 2022/6/6.
//

import Kingfisher
import SwiftUI

struct NFTShareView: View {
    @State var nft: NFTModel
    @State var colors: [Color]
    @State var name: String = "ZYANZ"

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                KFImage
                    .url(nft.logoUrl)
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .resizable()
                    .onSuccess { _ in
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20, alignment: .center)
                    .cornerRadius(20)
                    .clipped()
                    .padding(.trailing, 6)

                Text("from_name".localized(name.uppercased()))
                    .font(.LL.body)
                    .fontWeight(.w700)
                    .foregroundColor(.LL.Shades.front)
                Spacer()
                Text("@\(name)")
                    .font(.LL.body)
                    .fontWeight(.w700)
                    .foregroundColor(.LL.Shades.front)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                colors.count > 0 ? colors.first : Color.white
            )
            .cornerRadius(12)
            .clipped()

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(nft.title)
                        .font(.LL.largeTitle3)
                        .fontWeight(.w700)
                        .foregroundColor(.LL.Neutrals.text)
                        .frame(height: 28)
                    HStack(alignment: .center, spacing: 6) {
                        KFImage
                            .url(nft.logoUrl)
                            .placeholder({
                                Image("placeholder")
                                    .resizable()
                            })
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20, alignment: .center)
                            .cornerRadius(20)
                            .clipped()
                        Text(nft.subtitle)
                            .font(.LL.body)
                            .fontWeight(.w400)
                            .foregroundColor(.LL.Neutrals.neutrals4)
                    }
                }

                KFImage
                    .url(nft.imageURL)
                    .placeholder({
                        Image("placeholder")
                            .resizable()
                    })
                    .onSuccess { _ in
//                        color(from: result.image)
                    }
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(alignment: .center)
                    .cornerRadius(8)
                    .padding(.top, 24)
                    .clipped()
            }
            .cornerRadius(16)
            .background(Color.LL.background.opacity(0.48))

            HDashLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .foregroundColor(
                    colors.count > 0 ? colors[0].opacity(0.18) : .LL.Neutrals.background
                )

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    // TODO: app logo
                    Image("")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24, alignment: .center)
                        .cornerRadius(4)
                        .clipped()
                    VStack(alignment: .leading) {
                        Text("shared_via".localized.uppercased())
                            .font(.LL.miniTitle)
                            .fontWeight(.w600)
                            .foregroundColor(.LL.Neutrals.note)
                        HStack(spacing: 4) {
                            Text("lilico".localized.uppercased())
                                .font(.LL.miniTitle)
                                .fontWeight(Font.Weight.w600)
                                .foregroundColor(.LL.Neutrals.note)
                            HStack {}
                                .frame(width: 7, height: 3)
                                .cornerRadius(4)
                                .background(Color.LL.Primary.salmonPrimary)
                        }
                    }
                }
                Spacer()
                Image("")
                    .frame(width: 64, height: 64)
                    .cornerRadius(4)
            }
            .padding(.vertical, 12)
            .cornerRadius(16)
        }
        .background(
            NFTBlurImageView(colors: colors)
        )
        .padding(18)
    }
}

struct NFTShareView_Previews: PreviewProvider {
    static var previews: some View {
        NFTShareView(nft: NFTTabViewModel.testNFT(), colors: [])
    }
}
