//
//  PresentHostingController.swift
//  FRW
//
//  Created by cat on 2024/6/13.
//

import SwiftUI

//MARK: - Present Action

typealias PresentActionView = View & PresentActionDelegate

protocol PresentActionDelegate {
    func customViewDidDismiss()
    var detents: [UISheetPresentationController.Detent] { get }
    var prefersGrabberVisible: Bool { get }
}

extension PresentActionDelegate {
    
    var detents: [UISheetPresentationController.Detent] {
        return [.medium()]
    }
    
    var prefersGrabberVisible: Bool {
        return true
    }
    
    func customViewDidDismiss() {
        
    }
}

class PresentHostingController<Content: PresentActionView>: UIHostingController<Content>, UISheetPresentationControllerDelegate{
    
    public override init(rootView: Content) {
        super.init(rootView: rootView)
        self.overrideUserInterfaceStyle = ThemeManager.shared.getUIKitStyle()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        // setting presentation controller properties...
        if let presentationController = presentationController as? UISheetPresentationController
        {
            presentationController.detents = rootView.detents
            presentationController.prefersGrabberVisible = rootView.prefersGrabberVisible
            presentationController.delegate = self
        }
    }
    
    
    @objc func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        rootView.customViewDidDismiss()
    }
}
