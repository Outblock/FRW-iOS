//
//  SPQRMaskView.swift
//  Flow Wallet
//
//  Created by cat on 2023/7/25.
//

import UIKit

class SPQRMaskView: UIView {
    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internal

    internal let maskLayer = CAShapeLayer()
    internal let maskBorder = UIImageView(image: UIImage(named: "scan_border"))
    internal let padding = 35.0
    var top = 72.0
    var statusBarHeight = 20.0

    func config() {
        backgroundColor = .clear

        if let img = UIImage(named: "scan_border")?.withRenderingMode(.alwaysTemplate) {
            maskBorder.image = img
            maskBorder.tintColor = UIColor.LL.Primary.salmonPrimary
        }

        maskLayer.fillColor = UIColor(white: 0, alpha: 0.75).cgColor
        maskLayer.fillRule = .evenOdd
        layer.addSublayer(maskLayer)

        maskBorder.contentMode = .scaleAspectFit
        addSubviews(maskBorder)
    }

    override func layoutSubviews() {
        buildMaskPath()
    }

    // MARK:

    func buildMaskPath() {
        let rect = bounds
        let exceptSize = rect.width - 2 * padding
        let exceptRect = CGRect(x: padding, y: topMargin(), width: exceptSize, height: exceptSize)

        let coverPath = UIBezierPath(rect: rect)
        let scanPath = UIBezierPath()
        scanPath.lineJoinStyle = .round
        scanPath.lineCapStyle = .round

        let scanX = exceptRect.minX
        let scanY = exceptRect.minY
        let scanW = exceptRect.width
        let scanH = exceptRect.height
        let cornerRadius = 55.0

        // 左上圆角
        let leftTopCornerPoint = CGPoint(x: scanX + cornerRadius, y: scanY)
        let leftTopCenter = CGPoint(x: scanX + cornerRadius, y: scanY + cornerRadius)

        // 左下圆角
        let leftBottomCornerPoint = CGPoint(x: scanX, y: scanY + scanH - cornerRadius)
        let leftBottomCenter = CGPoint(x: scanX + cornerRadius, y: scanY + scanH - cornerRadius)

        // 右上圆角
        let rightTopCornerPoint = CGPoint(x: scanX + scanW, y: scanY + cornerRadius)
        let rightTopCenter = CGPoint(x: scanX + scanW - cornerRadius, y: scanY + cornerRadius)

        // 右下圆角
        let rightBottomCornerPoint = CGPoint(x: scanX + scanW - cornerRadius, y: scanY + scanH)
        let rightBottomCenter = CGPoint(
            x: scanX + scanW - cornerRadius,
            y: scanY + scanH - cornerRadius
        )

        scanPath.move(to: leftTopCornerPoint)
        scanPath.addArc(
            withCenter: leftTopCenter,
            radius: cornerRadius,
            startAngle: -.pi / 2,
            endAngle: -.pi,
            clockwise: false
        )

        scanPath.addLine(to: leftBottomCornerPoint)
        scanPath.addArc(
            withCenter: leftBottomCenter,
            radius: cornerRadius,
            startAngle: -.pi,
            endAngle: -.pi * 1.5,
            clockwise: false
        )

        scanPath.addLine(to: rightBottomCornerPoint)
        scanPath.addArc(
            withCenter: rightBottomCenter,
            radius: cornerRadius,
            startAngle: -.pi * 1.5,
            endAngle: 0,
            clockwise: false
        )

        scanPath.addLine(to: rightTopCornerPoint)
        scanPath.addArc(
            withCenter: rightTopCenter,
            radius: cornerRadius,
            startAngle: 0,
            endAngle: -.pi / 2,
            clockwise: false
        )
        scanPath.close()
        coverPath.append(scanPath)

        maskLayer.path = coverPath.cgPath
        maskBorder.frame = exceptRect.insetBy(dx: -16, dy: -16)
    }

    func topMargin() -> CGFloat {
        top + statusBarHeight + 44
    }
}
