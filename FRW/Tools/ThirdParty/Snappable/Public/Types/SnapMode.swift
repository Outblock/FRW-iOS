import UIKit

/// The modes that the snapping behavior of ScrollView.
///
/// It has the following two setting values depending on the snap timing.
/// - `.immediately`
/// - `.afterScrolling`
public struct SnapMode {
    // MARK: Public

    /// The default setting for snapping after scrolling.
    public static let afterScrolling: SnapMode = Self.afterScrolling(decelerationRate: .fast)
    /// The default setting for snapping immediately.
    public static let immediately: SnapMode = Self.immediately(
        decelerationRate: .normal,
        withFlick: true
    )

    /// An editable setting for snapping after scrolling.
    /// - Parameter decelerationRate: The deceleration rate of the ScrollView after dragging end.
    /// - Returns: SnapMode, edited as afterScrolling.
    public static func afterScrolling(decelerationRate: DecelerationRate) -> SnapMode {
        SnapMode(decelerationRate: decelerationRate, snapTiming: .afterScrolling)
    }

    /// An editable setting for snapping immediately.
    /// - Parameters:
    ///   - decelerationRate: The deceleration rate of the ScrollView after dragging end.
    ///   - withFlick: The flag whether or not do snapping in consideration of flicking.
    /// - Returns: SnapMode, edited as immediately.
    public static func immediately(
        decelerationRate: DecelerationRate,
        withFlick: Bool = true
    ) -> SnapMode {
        SnapMode(decelerationRate: decelerationRate, snapTiming: .immediately(withFlick: withFlick))
    }

    // MARK: Internal

    let decelerationRate: DecelerationRate
    let snapTiming: SnapTiming
}
