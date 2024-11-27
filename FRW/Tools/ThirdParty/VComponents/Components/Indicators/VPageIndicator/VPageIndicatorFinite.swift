//
//  VPageIndicatorFinite.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 2/6/21.
//

import SwiftUI

// MARK: - VPageIndicatorFinite

struct VPageIndicatorFinite: View {
    // MARK: Lifecycle

    // MARK: Intializers

    init(
        model: VPageIndicatorModel,
        total: Int,
        selectedIndex: Int
    ) {
        self.model = model
        self.total = total
        self.selectedIndex = selectedIndex
    }

    // MARK: Internal

    // MARK: Body

    var body: some View {
        HStack(spacing: model.layout.spacing, content: {
            ForEach(0 ..< total, content: { i in
                Circle()
                    .foregroundColor(
                        selectedIndex == i ? model.colors.selectedDot : model.colors
                            .dot
                    )
                    .frame(dimension: model.layout.dotDimension)
                    .scaleEffect(selectedIndex == i ? 1 : model.layout.finiteDotScale)
            })
        })
    }

    // MARK: Private

    // MARK: Properties

    private let model: VPageIndicatorModel

    private let total: Int
    private let selectedIndex: Int
}

// MARK: - VPageIndicatorFinite_Previews

struct VPageIndicatorFinite_Previews: PreviewProvider {
    static var previews: some View {
        VPageIndicatorFinite(model: .init(), total: 9, selectedIndex: 4)
    }
}
