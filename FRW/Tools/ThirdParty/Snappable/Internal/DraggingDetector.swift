import UIKit

class DraggingDetector: NSObject, UIScrollViewDelegate {
    // MARK: Lifecycle

    init(snapMode: SnapMode) {
        self.snapMode = snapMode
    }

    // MARK: Internal

    var captureSnapID: (() -> SnapID?)?
    var flickTarget: ((CGPoint) -> SnapID?)?
    var scrollTo: ((SnapID?) -> Void)?

    // MARK: UIScrollViewDelegate methods

    func scrollViewWillEndDragging(
        _: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset _: UnsafeMutablePointer<CGPoint>
    ) {
        guard case let .immediately(flickConsidered) = snapMode.snapTiming else { return }

        let currentSnapID = captureSnapID?()
        if flickConsidered {
            // The velocity in UIScrollViewDelegate is in points/millisecond
            // https://stackoverflow.com/a/40720012
            let pps = CGPoint(x: velocity.x * 1000, y: velocity.y * 1000)
            // The velocity detected as a flick would be 300 points/second
            // https://stackoverflow.com/a/49361860
            let isFlicked = pps.distance(.zero) >= 300

            if isFlicked {
                scrollTo?(flickTarget?(pps))
            } else {
                scrollTo?(currentSnapID)
            }
        } else {
            scrollTo?(currentSnapID)
        }
    }

    func scrollViewDidEndScrollingAnimation(_: UIScrollView) {
        guard case .immediately = snapMode.snapTiming else { return }

        let currentSnapID = captureSnapID?()
        scrollTo?(currentSnapID)
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        guard case .afterScrolling = snapMode.snapTiming else { return }

        if !decelerate {
            let currentSnapID = captureSnapID?()
            scrollTo?(currentSnapID)
        } else {
            // Wait for calling `scrollViewDidEndDecelerating`
        }
    }

    func scrollViewDidEndDecelerating(_: UIScrollView) {
        guard case .afterScrolling = snapMode.snapTiming else { return }

        let currentSnapID = captureSnapID?()
        scrollTo?(currentSnapID)
    }

    // MARK: Private

    private let snapMode: SnapMode
}
