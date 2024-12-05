//
//  HalfSheetModal.swift
//  ScrollToHide (iOS)
//
//  Created by Balaji on 08/07/21.
//

import SwiftUI

// MARK: - SheetHeaderView

struct SheetHeaderView: View {
    // MARK: Internal

    let title: String
    var closeAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()

                Button {
                    if let closeAction = closeAction {
                        closeAction()
                    } else {
                        defaultCloseAction()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(Color.LL.Neutrals.neutrals6)
                            .frame(width: 24, height: 24)

                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundColor(.LL.Neutrals.neutrals8)
                    }
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
                }
            }

            Text(title)
                .foregroundColor(.LL.Neutrals.text)
                .font(.inter(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, 10)
    }

    // MARK: Private

    private func defaultCloseAction() {
        Router.dismiss()
    }
}

// Custom Half Sheet Modifier....
extension View {
    // Binding Show Variable...
    func halfSheet<SheetView: View>(
        showSheet: Binding<Bool>,
        autoResizing: Bool = false,
        @ViewBuilder sheetView: @escaping () -> SheetView,
        onEnd: (() -> Void)? = nil
    ) -> some View {
        // why we using overlay or background...
        // bcz it will automatically use the swiftui frame Size only....
        background(
            HalfSheetHelper(sheetView: sheetView(), autoResizing: autoResizing, showSheet: showSheet)
        )
        .onChange(of: showSheet.wrappedValue) { newValue in
            if let onEnd = onEnd, !newValue {
                onEnd()
            }
        }
    }
}

// MARK: - HalfSheetHelper

// UIKit Integration...
struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    // On Dismiss...
    final class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        // MARK: Lifecycle

        init(parent: HalfSheetHelper) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: HalfSheetHelper

        func presentationControllerDidDismiss(_: UIPresentationController) {
            parent.showSheet = false
        }
    }

    var sheetView: SheetView
    let autoResizing: Bool
    @Binding var showSheet: Bool
    @State private var sheetSize: CGSize = .zero

    let controller = UIViewController()

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context _: Context) -> UIViewController {
        controller.view.backgroundColor = .clear
        controller.view.tag = 0
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if showSheet {
            if uiViewController.view.tag == 0 {
                let rootView = NavigationView {
                    sheetView
                        .padding(.bottom, 8)
                        .readSize { size in
                            self.sheetSize = size
                        }
                }
                .cornerRadius([.topLeading, .topTrailing], 16)
                .ignoresSafeArea()
                .persistentSystemOverlays(.hidden)
                .backgroundFill(Color.Theme.BG.bg1)

                let sheetController = CustomHostingController(
                    rootView: rootView,
                    sheetSize: self.autoResizing ? _sheetSize.projectedValue : nil
                )

                sheetController.presentationController?.delegate = context.coordinator
                uiViewController.present(sheetController, animated: true)
                uiViewController.view.tag = 1
            }
        } else {
            if uiViewController.view.tag == 1 {
                uiViewController.presentedViewController?.presentingViewController?
                    .dismiss(animated: true)
                uiViewController.view.tag = 0
            }
        }
    }
}

// MARK: - CustomHostingController

// Custom UIHostingController for halfSheet....
final class CustomHostingController<Content: View>: UIHostingController<Content> {
    private let sheetSize: Binding<CGSize>?
    
    // MARK: Lifecycle

    public init(
        rootView: Content,
        sheetSize: Binding<CGSize>? = nil,
        showLarge: Bool = false,
        showGrabber: Bool = true,
        onlyLarge: Bool = false
    ) {
        self.sheetSize = sheetSize
        self.showLarge = showLarge
        self.showGrabber = showGrabber
        self.onlyLarge = onlyLarge
        super.init(rootView: rootView)
        overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }

    @available(*, unavailable)
    @MainActor
    dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal
    private var autoResizing: Bool { return self.sheetSize != nil }
    private let showLarge: Bool
    private let showGrabber: Bool
    private let onlyLarge: Bool
    private let customDetentId = UISheetPresentationController.Detent.Identifier(rawValue: "custom-detent")
    private var customDetent: UISheetPresentationController.Detent {
        if #available(iOS 16, *), let sheetSize {
            return UISheetPresentationController.Detent.custom(identifier: self.customDetentId) { _ in
                return sheetSize.height.wrappedValue
            }
        } else {
            return UISheetPresentationController.Detent.medium()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        // setting presentation controller properties...
        if let sheetPresentationController {
            if onlyLarge {
                sheetPresentationController.detents = [.large()]
            } else {
                sheetPresentationController.detents = showLarge ? [customDetent, .large()] : [customDetent]
            }
            // to show grab protion...
            sheetPresentationController.prefersGrabberVisible = self.showLarge || self.onlyLarge
            
            if self.autoResizing {
                sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 16, *) {
            if let sheetPresentationController {
                sheetPresentationController.animateChanges {
                    sheetPresentationController.invalidateDetents()
                    self.view.setNeedsLayout()
                }
            }
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        view.setNeedsUpdateConstraints()
//    }
}
