import SwiftUI

struct SnapAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [SnapID: CGPoint] = [:]

    static func reduce(
        value: inout [SnapID: CGPoint],
        nextValue: () -> [SnapID: CGPoint]
    ) {
        for (id, anchor) in nextValue() {
            value[id] = anchor
        }
    }
}
