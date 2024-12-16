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
        backgroundColor: Color = .clear,
        @ViewBuilder sheetViewBuilder: @escaping () -> SheetView,
        onEnd: (() -> Void)? = nil
    ) -> some View {
        // why we using overlay or background...
        // bcz it will automatically use the swiftui frame Size only....
        background(
            HalfSheetHelper(showSheet: showSheet, sheetViewBuilder: SheetContainerView(sheetViewBuilder: sheetViewBuilder))
        )
        .background(backgroundColor)
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

    @Binding private var showSheet: Bool
    private var sheetViewBuilder: SheetContainerView<SheetView>
    private let controller = UIViewController()
    
    init(showSheet: Binding<Bool>, sheetViewBuilder: SheetContainerView<SheetView>) {
        self._showSheet = showSheet
        self.sheetViewBuilder = sheetViewBuilder
    }

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
                let sheetController = CustomHostingController(rootView: self.sheetViewBuilder)
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

final class SheetContainerViewModel: ObservableObject {
    @Published var sheetSize: CGSize = .zero
}

struct SheetContainerView<SheetView: View>: View {
    var viewModel: SheetContainerViewModel?
    @ViewBuilder private var sheetViewBuilder: () -> SheetView

    init(@ViewBuilder sheetViewBuilder: @escaping () -> SheetView) {
        self.sheetViewBuilder = sheetViewBuilder
    }
    
    var body: some View {
        NavigationView {
            self.sheetViewBuilder()
                .padding(.bottom, 8)
                .readSize { size in
                    print("[SIZE] \(size)")
                    self.viewModel?.sheetSize = size
                }
        }
        .cornerRadius([.topLeading, .topTrailing], 16)
        .ignoresSafeArea()
        .persistentSystemOverlays(.hidden)
    }
    
    func viewModel(_ viewModel: SheetContainerViewModel) -> Self {
        var view = self
        view.viewModel = viewModel
        return view
    }
}

func makeAutoResizeSheetViewController<Container: View>(_ view: Container) -> UIViewController {
    return CustomHostingController(rootView: SheetContainerView(sheetViewBuilder: { view }))
}

// MARK: - CustomHostingController

// Custom UIHostingController for halfSheet....
final class CustomHostingController<Content: View>: UIHostingController<SheetContainerView<Content>> {
    // MARK: Lifecycle
    private let viewModel = SheetContainerViewModel()
    
    override public init(rootView: SheetContainerView<Content>) {
        let view = rootView.viewModel(self.viewModel)
        super.init(rootView: view)
        overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }

    @available(*, unavailable)
    @MainActor
    dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal
    private let customDetentId = UISheetPresentationController.Detent.Identifier(rawValue: "custom-detent")
    private var customDetent: UISheetPresentationController.Detent {
        return UISheetPresentationController.Detent.custom(identifier: self.customDetentId) { _ in
            return self.rootView.viewModel?.sheetSize.height ?? 108 // This default value is the minimum allowed to prevent constraint errors
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        // setting presentation controller properties...
        if let sheetPresentationController {
            sheetPresentationController.detents = [customDetent]
            sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let sheetPresentationController {
            sheetPresentationController.animateChanges {
                sheetPresentationController.invalidateDetents()
                // This seems to cause the sheet not displayed when the parent is presented on the root navigation controller
                //self.view.setNeedsLayout()
            }
        }
    }
}
