//
//  LowerCapsuleView.swift
//  SwiftUI-Animations
//
//  Created by Shubham Singh on 26/09/20.
//  Copyright © 2020 Shubham Singh. All rights reserved.
//

import SwiftUI

// MARK: - LowerCapsuleView

struct LowerCapsuleView: View {
    let likeColor: Color

    // MARK: - variables

    @Binding
    var isAnimating: Bool

    // MARK: - views

    var body: some View {
        ZStack {
            ShrinkingCapsule(
                likeColor: likeColor,
                rotationAngle: .degrees(16),
                offset: CGSize(width: -42.5, height: 10),
                isAnimating: $isAnimating
            )
            ShrinkingCapsule(
                likeColor: likeColor,
                rotationAngle: .degrees(-16),
                offset: CGSize(width: 42.5, height: 10),
                isAnimating: $isAnimating
            )
            ShrinkingCapsule(
                likeColor: likeColor,
                rotationAngle: .degrees(48),
                offset: CGSize(width: -107, height: -30),
                isAnimating: $isAnimating
            )
            ShrinkingCapsule(
                likeColor: likeColor,
                rotationAngle: .degrees(-48),
                offset: CGSize(width: 107, height: -30),
                isAnimating: $isAnimating
            )
            ShrinkingCapsule(
                likeColor: likeColor,
                rotationAngle: .degrees(82),
                offset: CGSize(width: -142, height: -95),
                isAnimating: $isAnimating
            )
            ShrinkingCapsule(
                likeColor: likeColor,
                rotationAngle: .degrees(-82),
                offset: CGSize(width: 142, height: -95),
                isAnimating: $isAnimating
            )
        }
        .offset(y: 260)
    }
}

// MARK: - LowerCapsuleView_Previews

struct LowerCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        LowerCapsuleView(
            likeColor: .LL.Primary.salmonPrimary,
            isAnimating: .constant(false)
        )
    }
}
