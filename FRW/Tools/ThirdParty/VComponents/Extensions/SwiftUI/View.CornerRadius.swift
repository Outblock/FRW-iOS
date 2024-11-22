//
//  View.CornerRadius.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 10/28/21.
//

import SwiftUI

// MARK: - Corner Radius

extension View {
    /// Clips this view to its bounding frame, with the specified corners and corner radius.
    public func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

// MARK: - CornerRadiusShape

private struct CornerRadiusShape: Shape {
    // MARK: Lifecycle

    // MARK: Initializers

    init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    // MARK: Internal

    // MARK: Shape

    func path(in rect: CGRect) -> Path {
        .init(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: .init(width: radius, height: radius)
        ).cgPath)
    }

    // MARK: Private

    // MARK: Properties

    private let radius: CGFloat
    private let corners: UIRectCorner
}
