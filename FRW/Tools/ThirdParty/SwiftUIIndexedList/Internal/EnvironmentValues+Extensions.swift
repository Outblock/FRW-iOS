/**
 *  SwiftUIIndexedList
 *  Copyright (c) Ciaran O'Brien 2022
 *  MIT license, see LICENSE file for details
 */

import SwiftUI

extension EnvironmentValues {
    var indexBarBackground: IndexBarBackground {
        get { self[IndexBarBackgroundKey.self] }
        set { self[IndexBarBackgroundKey.self] = newValue }
    }

    var internalIndexBarInsets: EdgeInsets? {
        get { self[IndexBarInsetsKey.self] }
        set { self[IndexBarInsetsKey.self] = newValue }
    }
}

// MARK: - IndexBarBackgroundKey

private struct IndexBarBackgroundKey: EnvironmentKey {
    static let defaultValue = IndexBarBackground(contentMode: .fit, view: { AnyView(EmptyView()) })
}

// MARK: - IndexBarInsetsKey

private struct IndexBarInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInsets? = nil
}
