//
//  NFTSegmentControl.swift
//  Lilico
//
//  Created by cat on 2022/5/31.
//

import SwiftUI

struct NFTSegmentControl: View {
    @Binding var currentTab: NFTTabScreen.ViewStyle
    var styles: [NFTTabScreen.ViewStyle]

    @Namespace var animation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(styles, id: \.self) { style in
                NFTSegmentItem(thisStyle: style, animation: animation, current: $currentTab)
            }
        }
        .padding(4)
        .background(.LL.Neutrals.neutrals3.opacity(0.24))
        .cornerRadius(16)
    }
}

struct NFTSegmentItem: View {
    var thisStyle: NFTTabScreen.ViewStyle
    let animation: Namespace.ID

    @Binding var current: NFTTabScreen.ViewStyle

    var body: some View {
        Text(thisStyle.desc)
            .font(.LL.body)
            .fontWeight(.w700)
            .foregroundColor(current == thisStyle ? .LL.Neutrals.text : .LL.Shades.front)
            .frame(height: 20)
            .padding(.vertical, 2)
            .padding(.horizontal, 13)
            .background(
                ZStack {
                    if current == thisStyle {
                        Color.LL.Shades.front
                            .cornerRadius(16)
                            .matchedGeometryEffect(id: "Segment", in: animation)
                    }
                }
            )
            .animation(.easeInOut, value: current)
            .onTapGesture {
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6)) {
                    current = thisStyle
                }
            }
    }
}

//struct NFTSegmentControl_Previews: PreviewProvider {
//    @State static var current: String = "List"
//    static var previews: some View {
//        NFTSegmentControl(currentTab: $current, titles: ["List", "Grid"])
//            .previewLayout(.fixed(width: 300, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/))
//            .preferredColorScheme(.light)
//            .background(Color.black)
//        NFTSegmentControl(currentTab: $current, titles: ["List", "Grid"])
//            .previewLayout(.fixed(width: 300, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/))
//            .preferredColorScheme(.dark)
//            .background(Color.black)
//    }
//}
