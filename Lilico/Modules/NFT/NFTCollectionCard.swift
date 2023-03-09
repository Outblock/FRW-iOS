//
//  NFTCollectionCard.swift
//  Lilico
//
//  Created by cat on 2022/5/14.
//

import Kingfisher
import SwiftUI

struct NFTCollectionCard: View {
    let index: Int
    var item: CollectionItem
    let isHorizontal: Bool
    @Binding var selectedIndex: Int

    @EnvironmentObject private var viewModel: NFTTabViewModel

    private var iconSize: Double {
        return isHorizontal ? 40 : 48
    }

    var body: some View {
        HStack {
            KFImage
                .url(item.iconURL)
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(width: iconSize, height: iconSize)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 3) {
                    Text(item.showName)
                        .font(.LL.body)
                        .bold()
                        .foregroundColor(.LL.neutrals1)

                    Image("Flow")
                        .resizable()
                        .frame(width: 12, height: 12)
                }

                Text("x_collections".localized(item.count))
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
            }
            if !isHorizontal {
                Spacer()
                Image(systemName: "arrow.forward")
                    .foregroundColor(.LL.Primary.salmonPrimary)
                    .padding(.trailing, 8)
            }
        }
        .padding(8)
        .background(.LL.frontColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.LL.text,
                        lineWidth:
                        (isHorizontal && selectedIndex == index) ? 1 : 0)
        )
        .shadow(color: .LL.rebackground.opacity(0.05),
                radius: 8, x: 0, y: 0)
        .onTapGesture {
            if isHorizontal {
                selectedIndex = index
            } else {
                
            }
        }
        .frame(height: isHorizontal ? 56 : 64)
    }
}

//struct NFTCollectionCard_Previews: PreviewProvider {
//    @State static var selectedIndex: Int = 0
//
//    static var previews: some View {
//        VStack {
//            NFTCollectionCard(index: 0, item: NFTTabViewModel().state.items.first!,
//                              isHorizontal: true,
//                              selectedIndex: $selectedIndex)
//            NFTCollectionCard(index: 0,
//                              item: NFTTabViewModel().state.items.first!,
//                              isHorizontal: false,
//                              selectedIndex: $selectedIndex)
//        }
//    }
//}
