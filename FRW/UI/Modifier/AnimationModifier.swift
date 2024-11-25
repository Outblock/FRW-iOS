//
//  AnimationModifier.swift
//  Flow Wallet
//
//  Created by Selina on 1/6/2023.
//

import SwiftUI

// MARK: - AnimatableGradientModifier

struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content _: Content) -> some View {
        var gradientColors = [Color]()

        for i in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[i].color)
            let toColor = UIColor(toGradient.stops[i].color)

            gradientColors.append(colorMixer(
                fromColor: fromColor,
                toColor: toColor,
                progress: progress
            ))
        }

        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else { return Color(fromColor) }
        guard let toColor = toColor.cgColor.components else { return Color(toColor) }

        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress

        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

extension View {
    func animatableGradient(
        fromGradient: Gradient,
        toGradient: Gradient,
        progress: CGFloat
    ) -> some View {
        modifier(AnimatableGradientModifier(
            fromGradient: fromGradient,
            toGradient: toGradient,
            progress: progress
        ))
    }
}
