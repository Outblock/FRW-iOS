//
//  BrowserProgressView.swift
//  Flow Wallet
//
//  Created by Selina on 1/9/2022.
//

import UIKit

class BrowserProgressView: UIView {
    var progress: Double = 0 {
        didSet {
            reloadView()
        }
    }

    private lazy var progressLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        let color = UIColor(named: "primary.salmonPrimary") ?? UIColor.white
        layer.colors = [color.alpha(0.24).cgColor, color.cgColor]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.locations = [0.2, 1.0]

        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setup() {
        backgroundColor = .clear
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reloadView()
    }

    private func reloadView() {
        var frame = bounds
        frame.size.width *= min(1, max(0, progress))

        progressLayer.frame = frame
    }
}
