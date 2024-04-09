//
//  PageIndictor.swift
//  Flow Wallet-lite
//
//  Created by Hao Fu on 29/11/21.
//

import SwiftUI

struct PageIndictor: View {
    var indicatorOffset: CGFloat
    var currentIndex: Int
    var count: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0 ..< count) { index in
                Capsule()
                    .fill(currentIndex == index ? .yellow : .primary)
                    .frame(width: currentIndex == index ? 20 : 7, height: 7)
            }
        }
        .overlay(
            Capsule()
                .fill(.yellow)
                .frame(width: 20, height: 7)
                .offset(x: indicatorOffset),

            alignment: .leading
        )
    }
}
