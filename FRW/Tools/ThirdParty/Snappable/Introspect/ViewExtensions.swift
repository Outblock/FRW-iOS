import SwiftUI
import UIKit

extension View {
    func sn_inject<SomeView>(_ view: SomeView) -> some View where SomeView: View {
        overlay(view.frame(width: 0, height: 0))
    }
}

extension View {
    /// Finds a `TargetView` from a `SwiftUI.View`
    func sn_introspect<TargetView: UIView>(
        selector: @escaping (IntrospectionUIView) -> TargetView?,
        customize: @escaping (TargetView) -> Void
    ) -> some View {
        sn_inject(UIKitIntrospectionView(
            selector: selector,
            customize: customize
        ))
    }

    /// Finds a `UIScrollView` from a `SwiftUI.ScrollView`, or `SwiftUI.ScrollView` child.
    func sn_introspectScrollView(customize: @escaping (UIScrollView) -> Void) -> some View {
        sn_introspect(selector: TargetViewSelector.siblingOfTypeOrAncestor, customize: customize)
    }
}
