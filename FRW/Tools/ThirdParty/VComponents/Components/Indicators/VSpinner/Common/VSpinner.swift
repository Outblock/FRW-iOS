//
//  VSpinner.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 18.12.20.
//

import SwiftUI

// MARK: - V Spinner

/// Indicator component that indicates activity.
///
/// Model can be passed as parameter.
///
/// Usage example:
///
///     var body: some View {
///         VSpinner()
///     }
///
public struct VSpinner: View {
    // MARK: Proeprties

    private let spinnerType: VSpinnerType

    // MARK: Initializers

    /// Initializes component.
    public init(
        type spinnerType: VSpinnerType = .default
    ) {
        self.spinnerType = spinnerType
    }

    // MARK: Body

    @ViewBuilder public var body: some View {
        switch spinnerType {
        case let .continous(model): VSpinnerContinous(model: model)
        case let .dashed(model): VSpinnerDashed(model: model)
        }
    }
}

// MARK: - Preview

struct VSpinner_Previews: PreviewProvider {
    static var previews: some View {
        VSpinner()
    }
}
