import SwiftUI

// MARK: - SnapAlignmentEnvironmentKey

struct SnapAlignmentEnvironmentKey: EnvironmentKey {
    static var defaultValue: SnapAlignment = .center
}

extension EnvironmentValues {
    var snapAlignment: SnapAlignment {
        get { self[SnapAlignmentEnvironmentKey.self] }
        set { self[SnapAlignmentEnvironmentKey.self] = newValue }
    }
}
