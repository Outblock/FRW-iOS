//
//  NFTBlurImageView.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/29.
//

import Kingfisher
import SwiftUI

// MARK: - NFTBlurImageView

struct NFTBlurImageView: View {
    var colors: [Color]

    var color1: [Color] {
        [colors[0], colors[4]]
    }

    var color2: [Color] {
        [colors[1], colors[3]]
    }

    var color3: [Color] {
        [colors[0], colors[2], colors[4]]
    }

    var body: some View {
        ZStack {
            if colors.count > 4 {
                ZStack(alignment: .topLeading) {
                    ThirdShape()
                        .foregroundStyle(.linearGradient(
                            colors: color3,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 340, height: 878)
                        .padding(.top, -30)
                        .padding(.leading, -20)
                        .opacity(0.8)

                    SecondShape()
                        .foregroundStyle(.linearGradient(
                            colors: color2,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 408, height: 574)
                        .padding(.top, 74)
                        .zIndex(80)
                        .opacity(0.8)

                    FirstShape()
                        .foregroundStyle(.linearGradient(
                            colors: color1,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 348, height: 421, alignment: .topTrailing)
                        .padding(.top, -17)
                        .padding(.leading, 106)
                        .zIndex(100)
                        .opacity(0.8)
                }
                .ignoresSafeArea()
                .background(
                    LinearGradient(
                        colors: [.LL.Shades.front.opacity(0), .LL.Neutrals.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .blur(radius: 10)
                .mask(
                    LinearGradient(gradient: Gradient(
                        colors:
                        [Color.black, Color.clear]
                    ), startPoint: .top, endPoint: .center)
                )
            }
        }
    }
}

// MARK: - NFTBlurImageView_Previews

struct NFTBlurImageView_Previews: PreviewProvider {
    static var colors: [Color] = [
        .orange,
        .white,
        .blue,
        .black,
        .gray,
        .red,
        .purple,
    ]

    static var previews: some View {
        NFTBlurImageView(colors: colors)
    }
}

// MARK: - FirstShape

struct FirstShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.06691 * width, y: 0.52099 * height))
        path.addCurve(
            to: CGPoint(x: 0.22305 * width, y: -0.02222 * height),
            control1: CGPoint(x: -0.00867 * width, y: 0.42017 * height),
            control2: CGPoint(x: -0.08327 * width, y: 0.17037 * height)
        )
        path.addLine(to: CGPoint(x: 1.15428 * width, y: -0.04321 * height))
        path.addCurve(
            to: CGPoint(x: 0.88104 * width, y: 0.99753 * height),
            control1: CGPoint(x: 1.30731 * width, y: 0.29918 * height),
            control2: CGPoint(x: 1.46691 * width, y: 0.98667 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.06691 * width, y: 0.52099 * height),
            control1: CGPoint(x: 0.29517 * width, y: 1.0084 * height),
            control2: CGPoint(x: 0.09418 * width, y: 0.68436 * height)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - SecondShape

struct SecondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.01067 * width, y: 0.16261 * height))
        path.addCurve(
            to: CGPoint(x: 0.51867 * width, y: 0),
            control1: CGPoint(x: 0.10987 * width, y: 0.05757 * height),
            control2: CGPoint(x: 0.39067 * width, y: 0.01043 * height)
        )
        path.addLine(to: CGPoint(x: 1.07333 * width, y: 0))
        path.addLine(to: CGPoint(x: 1.07333 * width, y: 0.99913 * height))
        path.addLine(to: CGPoint(x: 0.89867 * width, y: 0.99913 * height))
        path.addCurve(
            to: CGPoint(x: 0.23067 * width, y: 0.61217 * height),
            control1: CGPoint(x: 0.66445 * width, y: 0.97826 * height),
            control2: CGPoint(x: 0.20293 * width, y: 0.87165 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.01067 * width, y: 0.16261 * height),
            control1: CGPoint(x: 0.26533 * width, y: 0.28783 * height),
            control2: CGPoint(x: -0.11333 * width, y: 0.29391 * height)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - ThirdShape

struct ThirdShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        path.move(to: CGPoint(x: 0.74169 * width, y: -0.03387 * height))
        path.addLine(to: CGPoint(x: -0.03172 * width, y: -0.03387 * height))
        path.addLine(to: CGPoint(x: -0.03172 * width, y: 1.02155 * height))
        path.addCurve(
            to: CGPoint(x: 0.37613 * width, y: 1.04618 * height),
            control1: CGPoint(x: -0.03172 * width, y: 1.03161 * height),
            control2: CGPoint(x: 0.04985 * width, y: 1.05062 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.96526 * width, y: 0.7383 * height),
            control1: CGPoint(x: 0.78399 * width, y: 1.04064 * height),
            control2: CGPoint(x: 1.10121 * width, y: 0.86022 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.42447 * width, y: 0.56096 * height),
            control1: CGPoint(x: 0.82931 * width, y: 0.61638 * height),
            control2: CGPoint(x: 0.63595 * width, y: 0.67549 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.74169 * width, y: 0.117 * height),
            control1: CGPoint(x: 0.21299 * width, y: 0.44643 * height),
            control2: CGPoint(x: 0.35801 * width, y: 0.23153 * height)
        )
        path.addCurve(
            to: CGPoint(x: 0.74169 * width, y: -0.03387 * height),
            control1: CGPoint(x: 1.04864 * width, y: 0.02537 * height),
            control2: CGPoint(x: 0.86959 * width, y: -0.02176 * height)
        )
        path.closeSubpath()
        return path
    }
}
