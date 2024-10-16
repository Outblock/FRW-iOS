//
//  UpperCapsuleView.swift
//  SwiftUI-Animations
//
//  Created by Shubham Singh on 26/09/20.
//  Copyright © 2020 Shubham Singh. All rights reserved.
//

import SwiftUI

struct CapusuleGroupView: View {
    let likeColor: Color

    // MARK: - variables

    @Binding var isAnimating: Bool

    // MARK: - views

    var body: some View {
        ZStack {
            ShrinkingCapsule(likeColor: likeColor, rotationAngle: .zero, offset: CGSize(width: 0, height: -15), isAnimating: $isAnimating)
            ShrinkingCapsule(likeColor: likeColor, rotationAngle: .degrees(-33), offset: CGSize(width: -40, height: 7.5), isAnimating: $isAnimating)
            ShrinkingCapsule(likeColor: likeColor, rotationAngle: .degrees(33), offset: CGSize(width: 40, height: 7.5), isAnimating: $isAnimating)
            ShrinkingCapsule(likeColor: likeColor, rotationAngle: .degrees(-65), offset: CGSize(width: -67, height: 35), isAnimating: $isAnimating)
            ShrinkingCapsule(likeColor: likeColor, rotationAngle: .degrees(65), offset: CGSize(width: 67, height: 35), isAnimating: $isAnimating)
            LowerCapsuleView(likeColor: likeColor, isAnimating: $isAnimating)
        }
        .onTapGesture {
            self.isAnimating.toggle()
        }
    }
}

struct UpperCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        CapusuleGroupView(likeColor: .LL.Primary.salmonPrimary, isAnimating: .constant(false))
    }
}
