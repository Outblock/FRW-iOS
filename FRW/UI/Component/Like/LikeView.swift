//
//  LikeView.swift
//  SwiftUI-Animations
//
//  Created by Shubham Singh on 26/09/20.
//  Copyright © 2020 Shubham Singh. All rights reserved.
//

import SwiftUI

// MARK: - LikeView

struct LikeView: View {
    let likeColor: Color

    // MARK: - variables

    let animationDuration: Double = 0.25

    @State
    var isAnimating: Bool = false
    @State
    var shrinkIcon: Bool = false
    @State
    var floatLike: Bool = false
    @State
    var showFlare: Bool = false

    // MARK: - views

    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)
            ZStack {
                if floatLike {
                    CapusuleGroupView(likeColor: likeColor, isAnimating: $floatLike)
                        .offset(y: -0)
                        .scaleEffect(self.showFlare ? 1.25 : 0.8)
                        .opacity(self.floatLike ? 1 : 0)
                        .animation(
                            Animation.spring().delay(animationDuration / 2),
                            value: floatLike
                        )
                }
                Circle()
                    .stroke(likeColor, lineWidth: 2)
                    .foregroundColor(self.isAnimating ? likeColor.opacity(0.2) : .clear)
                    .foregroundColor(self.floatLike ? likeColor.opacity(0.5) : .clear)
                    .animation(
                        Animation.easeOut(duration: animationDuration * 2)
                            .delay(animationDuration)
                    )

                HeartImageView(isLike: $floatLike)
                    .foregroundColor(likeColor)
//                    .offset(y: 12)
                    .scaleEffect(self.isAnimating ? 1.25 : 1)
                    .overlay(
                        likeColor
                            .mask(
                                HeartImageView(isLike: $floatLike)
                            )
                            .scaleEffect(self.isAnimating ? 1.35 : 0)
                            .animation(Animation.easeIn(duration: animationDuration))
                            .opacity(self.isAnimating ? 0 : 1)
                            .animation(
                                Animation.easeIn(duration: animationDuration)
                                    .delay(animationDuration)
                            )
                    )
            }.frame(width: 44, height: 44)
                .scaleEffect(self.shrinkIcon ? 0.35 : 1)
                .animation(Animation.spring(
                    response: animationDuration,
                    dampingFraction: 1,
                    blendDuration: 1
                ))
            if floatLike {
                FloatingLike(likeColor: likeColor, isAnimating: $floatLike)
                    .offset(y: -40)
            }
        }.onTapGesture {
            if !floatLike {
                self.floatLike.toggle()
                self.isAnimating.toggle()
                self.shrinkIcon.toggle()
                Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
                    self.shrinkIcon.toggle()
                    self.showFlare.toggle()
                }
            } else {
                self.isAnimating = false
                self.shrinkIcon = false
                self.showFlare = false
                self.floatLike = false
            }
        }
    }
}

// MARK: - LikeButton_Previews

struct LikeButton_Previews: PreviewProvider {
    static var previews: some View {
        LikeView(likeColor: .LL.Primary.salmonPrimary)
            .previewLayout(.sizeThatFits)
    }
}
