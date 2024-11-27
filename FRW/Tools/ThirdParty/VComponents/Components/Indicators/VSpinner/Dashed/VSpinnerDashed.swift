//
//  VSpinnerDashed.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 12/21/20.
//

import SwiftUI

// MARK: - VSpinnerDashed

struct VSpinnerDashed: View {
    // MARK: Lifecycle

    // MARK: Initializers

    init(model: VSpinnerModelDashed) {
        self.model = model
    }

    // MARK: Internal

    // MARK: Body

    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: model.colors.spinner))
    }

    // MARK: Private

    // MARK: Properties

    private let model: VSpinnerModelDashed
}

// MARK: - VSpinnerDashed_Previews

struct VSpinnerDashed_Previews: PreviewProvider {
    static var previews: some View {
        VSpinnerDashed(model: .init())
    }
}
