//
//  WindowOverlayView.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/21/21.
//

import SwiftUI

// MARK: - WindowOverlayView

struct WindowOverlayView<Content>: UIViewControllerRepresentable where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers

    init(
        allowsHitTesting: Bool = true,
        isPresented: Binding<Bool>,
        content: Content
    ) {
        self.allowsHitTesting = allowsHitTesting
        _isPresented = isPresented
        self.content = content
    }

    // MARK: Internal

    // MARK: Representabe

    func makeUIViewController(context _: Context) -> WindowOverlayViewController<Content> {
        .init(allowsHitTesting: allowsHitTesting, content: content)
    }

    func updateUIViewController(
        _ uiViewController: WindowOverlayViewController<Content>,
        context _: Context
    ) {
        switch isPresented {
        case false: uiViewController.dismiss()
        case true: uiViewController.update(with: content)
        }
    }

    // MARK: Private

    // MARK: Properties

    private let allowsHitTesting: Bool
    @Binding
    private var isPresented: Bool
    private let content: Content
}

// MARK: - WindowOverlayViewController

final class WindowOverlayViewController<Content>: UIViewController where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers

    convenience init(
        allowsHitTesting: Bool,
        content: Content
    ) {
        self.init(nibName: nil, bundle: nil)

        present(
            allowsHitTesting: allowsHitTesting,
            content: content
        )
    }

    // MARK: Fileprivate

    // MARK: Updating

    fileprivate func update(with content: Content) {
        hostingController?.rootView = content
    }

    // MARK: Dismissing

    fileprivate func dismiss() {
        UIView.appRootView?.subviews.first(where: { $0.tag == hostedViewTag })?
            .removeFromSuperview()
    }

    // MARK: Private

    // MARK: Properties

    private let hostedViewTag: Int = 999_999_999
    private var hostingController: UIHostingController<Content>!

    // MARK: Presenting

    private func present(
        allowsHitTesting: Bool,
        content: Content
    ) {
        hostingController = .init(rootView: content)

        let hostedView: UIView = hostingController.view
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        hostedView.isUserInteractionEnabled = allowsHitTesting
        hostedView.backgroundColor = .clear
        hostedView.tag = hostedViewTag

        guard let windowView = UIView.appRootView else { fatalError() }

        windowView.addSubview(hostedView)

        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: windowView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: windowView.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: windowView.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: windowView.bottomAnchor),
        ])

        windowView.bringSubviewToFront(hostedView)
    }
}

// MARK: - Helpers

private extension UIView {
    static var appRootView: UIView? {
        guard let window: UIWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let viewController: UIViewController = window.rootViewController,
              let view: UIView = viewController.view
        else {
            return nil
        }

        return view
    }
}
