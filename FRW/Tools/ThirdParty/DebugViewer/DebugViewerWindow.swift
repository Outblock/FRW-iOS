//
//  DebugViewerWindow.swift
//
//
//  Created by Jin Kim on 6/13/22.
//

import UIKit

extension UIWindow {
    override open func addSubview(_ view: UIView) {
        super.addSubview(view)
        guard isKeyWindow else { return }
        DebugViewer.shared.alwaysShowOnTop()
    }
}
