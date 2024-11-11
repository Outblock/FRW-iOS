//
//  ContextMenuPreview.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/26.
//

import SwiftUI

struct ContextMenuPreview<Content: View, Preview: View>: View {
    var content: Content
    var preview: Preview

    var menu: UIMenu
    var onEnd: () -> Void

    init(@ViewBuilder content: @escaping () -> Content, preview: @escaping () -> Preview, menu: @escaping () -> UIMenu, onEnd: @escaping () -> Void) {
        self.content = content()
        self.preview = preview()
        self.menu = menu()
        self.onEnd = onEnd
    }

    var body: some View {
        ZStack {
            content
                .hidden()
                .overlay {
                    ContextMenuHelper(content: content, preview: preview, actions: menu, onEnd: onEnd)
                }
        }
    }
}

struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable {
    var content: Content
    var preview: Preview
    var actions: UIMenu
    var onEnd: () -> Void

    init(content: Content, preview: Preview, actions: UIMenu, onEnd: @escaping () -> Void) {
        self.content = content
        self.preview = preview
        self.actions = actions
        self.onEnd = onEnd
    }

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let hostView = UIHostingController(rootView: content)
        hostView.view?.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
        ]
        view.addSubview(hostView.view)
        view.addConstraints(constraints)

        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)

        return view
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func updateUIView(_: UIViewType, context _: Context) {}

    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }

        func contextMenuInteraction(_: UIContextMenuInteraction, configurationForMenuAtLocation _: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil) {
                let previewController = UIHostingController(rootView: self.parent.preview)
                previewController.view.backgroundColor = .clear
                previewController.view.frame = CGRect(x: 0, y: 0, width: 200, height: 60)
                return previewController
            } actionProvider: { _ in
                self.parent.actions
            }
        }

        func contextMenuInteraction(_: UIContextMenuInteraction, willPerformPreviewActionForMenuWith _: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
            animator.addCompletion {
                self.parent.onEnd()
            }
        }
    }
}

struct ContextMenuPreview_Previews: PreviewProvider {
    static let children = [
        UIAction(title: "top_selection".localized, image: UIImage(named: "nft_logo_star")) { _ in
            print("Like ")
        },
    ]
    static var previews: some View {
        ContextMenuPreview {
            Text("Hello")
                .foregroundColor(.red)
        } preview: {
            Text("Wolr")
                .frame(width: 200, height: 60)
                .background(Color.purple)
        } menu: {
            let like = UIAction(title: "top_selection".localized, image: UIImage(named: "nft_logo_star")) { _ in
                print("Like ")
            }

            let share = UIAction(title: "share".localized, image: UIImage(systemName: "square.adn.arrow.up.fill")) { _ in
                print("Share")
            }

            let send = UIAction(title: "send".localized, image: UIImage(systemName: "paperplane")) { _ in
                print("Share")
            }

            return UIMenu(title: "", children: [like, share, send])
        } onEnd: {}
    }
}
