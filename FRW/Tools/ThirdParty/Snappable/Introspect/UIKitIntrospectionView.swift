import SwiftUI
import UIKit

// MARK: - IntrospectionUIView

/// Introspection UIView that is inserted alongside the target view.
class IntrospectionUIView: UIView {
    // MARK: Lifecycle

    required init() {
        super.init(frame: .zero)
        isHidden = true
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    var didMoveToWindowHandler: (() -> Void)?

    override func didMoveToWindow() {
        didMoveToWindowHandler?()
    }
}

// MARK: - UIKitIntrospectionView

/// Introspection View that is injected into the UIKit hierarchy alongside the target view.
/// After `updateUIView` is called, it calls `selector` to find the target view, then `customize` when the target view is found.
struct UIKitIntrospectionView<TargetViewType: UIView>: UIViewRepresentable {
    // MARK: Lifecycle

    init(
        selector: @escaping (IntrospectionUIView) -> TargetViewType?,
        customize: @escaping (TargetViewType) -> Void
    ) {
        self.selector = selector
        self.customize = customize
    }

    // MARK: Internal

    /// Method that introspects the view hierarchy to find the target view.
    /// First argument is the introspection view itself, which is contained in a view host alongside the target view.
    let selector: (IntrospectionUIView) -> TargetViewType?

    /// User-provided customization method for the target view.
    let customize: (TargetViewType) -> Void

    func makeUIView(context _: UIViewRepresentableContext<UIKitIntrospectionView>)
        -> IntrospectionUIView {
        let view = IntrospectionUIView()
        view.accessibilityLabel = "IntrospectionUIView<\(TargetViewType.self)>"
        return view
    }

    /// When `updateUiView` is called after creating the Introspection view, it is not yet in the UIKit hierarchy.
    /// At this point, `introspectionView.superview.superview` is nil and we can't access the target UIKit view.
    /// To workaround this, we wait until the introspection view did attach to the window and the runloop is done
    /// inserting the introspection view in the hierarchy, then run the selector.
    /// Finding the target view fails silently if the selector yield no result. This happens when `updateUIView`
    /// gets called when the introspection view gets removed from the hierarchy.
    func updateUIView(
        _ uiView: IntrospectionUIView,
        context _: UIViewRepresentableContext<UIKitIntrospectionView>
    ) {
        uiView.didMoveToWindowHandler = {
            DispatchQueue.main.async {
                guard let targetView = self.selector(uiView) else {
                    return
                }
                self.customize(targetView)
            }
        }
    }
}
