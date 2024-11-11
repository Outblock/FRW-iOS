//
//  TransactionProgressView.swift
//  Flow Wallet
//
//  Created by Selina on 29/8/2022.
//

import SnapKit
import SwiftUI
import UIKit

private let ProgressViewWidth: CGFloat = 32
private let IconImageViewWidth: CGFloat = 26

// MARK: - TransactionProgressView

class TransactionProgressView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("")
    }

    // MARK: Internal

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "flow")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 13

        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(IconImageViewWidth)
        }

        return imageView
    }()

    var progress: CGFloat = 0 {
        didSet {
            refreshProgress()
        }
    }

    func changeProgressColor(_ color: UIColor) {
        progressLayer.strokeColor = color.cgColor
    }

    // MARK: Private

    private lazy var progressBgLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(
            arcCenter: CGPoint(x: ProgressViewWidth / 2.0, y: ProgressViewWidth / 2.0),
            radius: ProgressViewWidth / 2.0,
            startAngle: 0,
            endAngle: Double.pi * 2,
            clockwise: true
        ).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.LL.Primary.salmonPrimary.alpha(0.1).cgColor
        layer.lineWidth = 4
        layer.lineCap = .round
        return layer
    }()

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        let startAngle = -Double.pi / 2.0
        layer.path = UIBezierPath(
            arcCenter: CGPoint(x: ProgressViewWidth / 2.0, y: ProgressViewWidth / 2.0),
            radius: ProgressViewWidth / 2.0,
            startAngle: startAngle,
            endAngle: Double.pi * 2 + startAngle,
            clockwise: true
        ).cgPath
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.LL.Primary.salmonPrimary.alpha(0.9).cgColor
        layer.lineWidth = 4
        layer.lineCap = .round
        layer.strokeEnd = 0.5
        return layer
    }()

    private func setup() {
        backgroundColor = .clear

        layer.addSublayer(progressBgLayer)
        layer.addSublayer(progressLayer)

        addSubviews(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.width.height.equalTo(ProgressViewWidth)
        }
    }

    private func refreshProgress() {
        progressLayer.strokeEnd = min(1, max(0, progress))
    }
}
