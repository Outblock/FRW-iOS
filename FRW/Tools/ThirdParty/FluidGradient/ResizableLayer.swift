//
//  ResizableLayer.swift
//  ResizableLayer
//
//  Created by João Gabriel Pozzobon dos Santos on 03/10/22.
//

import SwiftUI

/// An implementation of ``CALayer`` that resizes its sublayers
public class ResizableLayer: CALayer {
    // MARK: Lifecycle

    override init() {
        super.init()
        #if os(OSX)
        autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        #endif
        sublayers = []
    }

    override public init(layer: Any) {
        super.init(layer: layer)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    override public func layoutSublayers() {
        super.layoutSublayers()
        sublayers?.forEach { layer in
            layer.frame = self.frame
        }
    }
}
