//
//  VBaseListLayoutType.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/11/21.
//

import Foundation

// MARK: - V Base List Layout Type

/// Enum that describes layout, such as `fixed` or `flexible`.
///
/// There are three posible layouts:
///
/// 1. `Fixed`.
/// Passed as parameter. Component stretches vertically to take required space. Scrolling may be enabled on page.
///
/// 2. `Flexible`.
/// Passed as parameter. Component stretches vertically to occupy maximum space, but is constrainted in space given by container.Scrolling may be enabled inside component.
///
/// 3. `Constrained`.
/// `.frame()` modifier can be applied to view. Content would be limitd in vertical space. Scrolling may be enabled inside component.
public enum VBaseListLayoutType: Int, CaseIterable {
    // MARK: Cases

    /// Fixed layout.
    ///
    /// Component stretches vertically to take required space. Scrolling may be enabled on page.
    case fixed

    /// Flexible layout.
    ///
    /// Component stretches vertically to occupy maximum space, but is constrainted in space given by container. Scrolling may be enabled inside component.
    case flexible

    // MARK: Public

    // MARK: Initailizers

    /// Default value. Set to `flexible`.
    public static var `default`: Self { .flexible }
}
