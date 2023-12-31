//
//  View.CornerRadius.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 10/28/21.
//

import SwiftUI

// MARK: - Corner Radius

public extension View {
    /// Clips this view to its bounding frame, with the specified corners and corner radius.
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

// MARK: - Corner Radius Shape

private struct CornerRadiusShape: Shape {
    // MARK: Properties

    private let radius: CGFloat
    private let corners: UIRectCorner

    // MARK: Initializers

    init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    // MARK: Shape

    func path(in rect: CGRect) -> Path {
        .init(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: .init(width: radius, height: radius)
        ).cgPath)
    }
}
