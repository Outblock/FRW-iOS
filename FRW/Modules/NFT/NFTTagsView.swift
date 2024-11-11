//
//  NFTTagsView.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/17.
//

import SwiftUI

struct NFTTagsView: View {
    @State
    var tags: [NFTTrait]
    @State
    private var totalHeight = CGFloat.zero
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if abs(width - d.width) > g.size.width {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 // last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { _ in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    func item(for tag: NFTTrait) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text((tag.name ?? "").uppercased())
                .font(Font.inter(size: 11, weight: .w600))
                .foregroundColor(color)
                .frame(height: 14)
            Text(tag.value ?? "")
                .font(Font.inter(size: 14, weight: .w500))
                .foregroundColor(.LL.Neutrals.neutrals3)
                .frame(height: 16)
        }
        .cornerRadius(5)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    color,
                    lineWidth: 1
                )
        )
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// struct NFTTagsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NFTTagsView(tags: [NFTMetadatum(name: "School", value: "Impression")], color: Color(hex: 0x6D9987))
//    }
// }
