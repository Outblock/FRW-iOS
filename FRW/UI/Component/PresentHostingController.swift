//
//  PresentHostingController.swift
//  FRW
//
//  Created by cat on 2024/6/13.
//

import SwiftUI

// MARK: - Present Action

typealias PresentActionView = PresentActionDelegate & View


protocol PresentActionDelegate {
    func customViewDidDismiss()
    var detents: [UISheetPresentationController.Detent] { get }
    var prefersGrabberVisible: Bool { get }

    var changeHeight: (() -> ())? { get set }
}

extension PresentActionDelegate {
    
    var detents: [UISheetPresentationController.Detent] {
        return [.medium()]
    }

    var prefersGrabberVisible: Bool {
        return true
    }

    func customViewDidDismiss() {}
}





// MARK: PresentHostingController
class PresentHostingController<Content: PresentActionView>: UIHostingController<Content>, UISheetPresentationControllerDelegate {
    override public init(rootView: Content) {
        super.init(rootView: rootView)
        self.overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        // setting presentation controller properties...
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = rootView.detents
            presentationController.prefersGrabberVisible = rootView.prefersGrabberVisible
            presentationController.delegate = self
        }
        rootView.changeHeight = {
            self.changeHeight()
        }
    }

    func changeHeight() {
        guard let sheet = presentationController as? UISheetPresentationController else {
            return
        }
        let oldValue = sheet.selectedDetentIdentifier ?? .medium
        
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = oldValue.oppositeValue
        }
    }

    @objc func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        rootView.customViewDidDismiss()
    }
}

extension UISheetPresentationController.Detent.Identifier {
    var oppositeValue: UISheetPresentationController.Detent.Identifier {
        switch self {
        case .medium:
            return .large
        case .large:
            return .medium
        default:
            fatalError("Unsupported value")
        }
    }
}
