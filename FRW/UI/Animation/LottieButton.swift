//
//  LottieButton.swift
//  Flow Wallet
//
//  Created by Hao Fu on 22/8/2022.
//

import Foundation
import Lottie
import SwiftUI

struct LottieButton: View {
    var iconName: String
    var color: SwiftUI.Color
    var size: CGSize
    var padding: CGFloat
    var action: () -> Void
    var animationView: AnimationView!

    init(iconName: String,
         color: SwiftUI.Color = Color.LL.Neutrals.neutrals7,
         size: CGSize = CGSize(width: 25, height: 25),
         padding: CGFloat = 5,
         action: @escaping () -> Void)
    {
        self.iconName = iconName
        self.color = color
        self.size = size
        self.padding = padding
        self.action = action
        animationView = AnimationView(name: iconName, bundle: .main)
    }

    var body: some View {
        ResizableLottieView(lottieView: animationView,
                            color: color)
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width, height: size.height)
            .contentShape(Rectangle())
            .padding(padding)
            .onTapGesture {
                animationView.play()
                action()
            }
//        .background(.yellow)
    }
}

struct LottieButton_Previews: PreviewProvider {
    static var previews: some View {
        LottieButton(iconName: "inAR") {}.frame(width: 100, height: 100)
    }
}
