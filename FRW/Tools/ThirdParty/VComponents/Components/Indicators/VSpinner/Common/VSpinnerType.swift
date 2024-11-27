//
//  VSpinnerType.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 19.12.20.
//

import Foundation

// MARK: - V Spinner Type

/// Enum of types, such as `continous` or `dashed`
public enum VSpinnerType {
    // MARK: Cases

    /// Continos spinner.
    case continous(_ model: VSpinnerModelContinous = .init())

    /// Dashed spinner.
    case dashed(_ model: VSpinnerModelDashed = .init())

    // MARK: Public

    // MARK: Initailizers

    /// Default value. Set to `continous`.
    public static var `default`: Self { .continous() }
}
