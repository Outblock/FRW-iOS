//
//  CircularProgressView.swift
//  FRW
//
//  Created by cat on 2024/6/5.
//

import SwiftUI

// MARK: - CircularProgressBackground

struct CircularProgressBackground: View {
    @Binding
    var animationPhase: AnimationPhase

    var body: some View {
        Circle()
            .rotation(.degrees(-90))
            .stroke(
                Color.Theme.Accent.green.opacity(0.15),
                style: .init(lineWidth: 2, lineCap: .round)
            )
            .animation(.bouncy, value: animationPhase)
    }
}

// MARK: - CircularProgressIndicator

struct CircularProgressIndicator: View {
    @Binding
    var animationPhase: AnimationPhase

    var body: some View {
        Circle()
            .trim(from: animationPhase.values.from, to: animationPhase.values.to)
            .rotation(.degrees(-90))
            .stroke(
                Color.Theme.Accent.green,
                style: .init(lineWidth: animationPhase.values.lineWidth, lineCap: .round)
            )
            .shadow(
                color: .black.opacity(animationPhase == .sealed ? 0 : 0.1),
                radius: 10,
                x: 0,
                y: 5
            )
            .animation(.bouncy, value: animationPhase)
    }
}

private let initialAnimationValues: AnimationValues = .init(from: 0.0, to: 0.0, lineWidth: 1.0)
private let pendingAnimationValues: AnimationValues = .init(from: 0.0, to: 0.25, lineWidth: 3.0)
private let finalizedAnimationValues: AnimationValues = .init(from: 0.0, to: 0.5, lineWidth: 3.0)
private let executedAnimationValues: AnimationValues = .init(from: 0.0, to: 0.75, lineWidth: 0.01)
private let sealedAnimationValues: AnimationValues = .init(from: 1.0, to: 1.0, lineWidth: 0.01)

// MARK: - AnimationValues

struct AnimationValues {
    var from: CGFloat
    var to: CGFloat
    var lineWidth: CGFloat
}

// MARK: - AnimationPhase

enum AnimationPhase: Int {
    case initial = 0, pending, finalized, executed, sealed

    // MARK: Internal

    var values: AnimationValues {
        switch self {
        case .initial:
            initialAnimationValues
        case .pending:
            pendingAnimationValues
        case .finalized:
            finalizedAnimationValues
        case .executed:
            executedAnimationValues
        case .sealed:
            sealedAnimationValues
        }
    }
}
