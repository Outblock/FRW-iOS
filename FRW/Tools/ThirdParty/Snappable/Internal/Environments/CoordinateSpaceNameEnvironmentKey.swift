import SwiftUI

// MARK: - CoordinateSpaceNameEnvironmentKey

struct CoordinateSpaceNameEnvironmentKey: EnvironmentKey {
    static var defaultValue = UUID()
}

extension EnvironmentValues {
    var coordinateSpaceName: UUID {
        get { self[CoordinateSpaceNameEnvironmentKey.self] }
        set { self[CoordinateSpaceNameEnvironmentKey.self] = newValue }
    }
}
