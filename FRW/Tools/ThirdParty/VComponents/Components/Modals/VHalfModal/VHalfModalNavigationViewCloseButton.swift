//
//  VHalfModalNavigationViewCloseButton.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/22/21.
//

import SwiftUI

// MARK: - VHalfModalNavigationViewCloseButton

struct VHalfModalNavigationViewCloseButton: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var vHalfModalNavigationViewCloseButton: Bool {
        get { self[VHalfModalNavigationViewCloseButton.self] }
        set { self[VHalfModalNavigationViewCloseButton.self] = newValue }
    }
}
