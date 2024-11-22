//
//  QRCodeEyeShareFillCircle.swift
//  FRW
//
//  Created by cat on 2024/3/12.
//

import CoreGraphics
import Foundation
import QRCode
import UIKit

// MARK: - QRCode.EyeShape.FillCircle

extension QRCode.EyeShape {
    @objc(QRCodeEyeShapeFillCircle)
    public class FillCircle: NSObject, QRCodeEyeShapeGenerator {
        // MARK: Public

        @objc
        public static let Name: String = "fillCircle"

        @objc
        public static var Title: String { "FillCircle" }

        @objc
        public static func Create(_: [String: Any]?) -> QRCodeEyeShapeGenerator {
            QRCode.EyeShape.FillCircle()
        }

        // Has no configurable settings
        @objc
        public func settings() -> [String: Any] { [:] }
        @objc
        public func supportsSettingValue(forKey _: String) -> Bool { false }
        @objc
        public func setSettingValue(_: Any?, forKey _: String) -> Bool { false }

        /// Make a copy of the object
        @objc
        public func copyShape() -> QRCodeEyeShapeGenerator {
            Self.Create(settings())
        }

        public func eyePath() -> CGPath {
            let circleEyePath = CGMutablePath()
            circleEyePath.move(to: CGPoint(x: 45, y: 20))
            circleEyePath.curve(
                to: CGPoint(x: 20, y: 45),
                controlPoint1: CGPoint(x: 31.19, y: 20),
                controlPoint2: CGPoint(x: 20, y: 31.19)
            )
            circleEyePath.curve(
                to: CGPoint(x: 21.28, y: 52.92),
                controlPoint1: CGPoint(x: 20, y: 47.77),
                controlPoint2: CGPoint(x: 20.45, y: 50.43)
            )
            circleEyePath.curve(
                to: CGPoint(x: 45, y: 70),
                controlPoint1: CGPoint(x: 24.59, y: 62.85),
                controlPoint2: CGPoint(x: 33.96, y: 70)
            )
            circleEyePath.curve(
                to: CGPoint(x: 70, y: 45),
                controlPoint1: CGPoint(x: 58.81, y: 70),
                controlPoint2: CGPoint(x: 70, y: 58.81)
            )
            circleEyePath.curve(
                to: CGPoint(x: 45, y: 20),
                controlPoint1: CGPoint(x: 70, y: 31.19),
                controlPoint2: CGPoint(x: 58.81, y: 20)
            )
            circleEyePath.close()
            circleEyePath.move(to: CGPoint(x: 80, y: 45))
            circleEyePath.curve(
                to: CGPoint(x: 45, y: 80),
                controlPoint1: CGPoint(x: 80, y: 64.33),
                controlPoint2: CGPoint(x: 64.33, y: 80)
            )
            circleEyePath.curve(
                to: CGPoint(x: 11.64, y: 55.61),
                controlPoint1: CGPoint(x: 29.37, y: 80),
                controlPoint2: CGPoint(x: 16.13, y: 69.76)
            )
            circleEyePath.curve(
                to: CGPoint(x: 10, y: 45),
                controlPoint1: CGPoint(x: 10.57, y: 52.27),
                controlPoint2: CGPoint(x: 10, y: 48.7)
            )
            circleEyePath.curve(
                to: CGPoint(x: 45, y: 10),
                controlPoint1: CGPoint(x: 10, y: 25.67),
                controlPoint2: CGPoint(x: 25.67, y: 10)
            )
            circleEyePath.curve(
                to: CGPoint(x: 80, y: 45),
                controlPoint1: CGPoint(x: 64.33, y: 10),
                controlPoint2: CGPoint(x: 80, y: 25.67)
            )
            circleEyePath.close()
            return circleEyePath
        }

        @objc
        public func eyeBackgroundPath() -> CGPath {
            CGPath(
                ellipseIn: CGRect(origin: .zero, size: CGSize(width: 90, height: 90)),
                transform: nil
            )
        }

        public func defaultPupil() -> QRCodePupilShapeGenerator { Self._defaultPupil }

        // MARK: Private

        private static let _defaultPupil = QRCode.PupilShape.FillCircle()
    }
}

// MARK: - QRCode.PupilShape.FillCircle

extension QRCode.PupilShape {
    /// A circle style pupil design
    @objc(QRCodePupilShapeFillCircle)
    public class FillCircle: NSObject, QRCodePupilShapeGenerator {
        @objc
        public static var Name: String { "fillCircle" }
        /// The generator title
        @objc
        public static var Title: String { "FillCircle" }

        @objc
        public static func Create(_: [String: Any]?) -> QRCodePupilShapeGenerator {
            FillCircle()
        }

        /// Make a copy of the object
        @objc
        public func copyShape() -> QRCodePupilShapeGenerator { FillCircle() }

        @objc
        public func settings() -> [String: Any] { [:] }
        @objc
        public func supportsSettingValue(forKey _: String) -> Bool { false }
        @objc
        public func setSettingValue(_: Any?, forKey _: String) -> Bool { false }

        /// The pupil centered in the 90x90 square
        @objc
        public func pupilPath() -> CGPath {
            CGPath(ellipseIn: CGRect(x: 30, y: 30, width: 30, height: 30), transform: nil)
        }
    }
}

extension CGMutablePath {
    @inlinable @inline(__always)
    func curve(
        to endPoint: CGPoint,
        controlPoint1: CGPoint,
        controlPoint2: CGPoint
    ) {
        addCurve(to: endPoint, control1: controlPoint1, control2: controlPoint2)
    }

    @inlinable @inline(__always)
    func line(to point: CGPoint) { addLine(to: point) }
    @inlinable @inline(__always)
    func close() { closeSubpath() }
}
