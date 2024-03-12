//
//  QRCodeEyeShareFillCircle.swift
//  FRW
//
//  Created by cat on 2024/3/12.
//

import Foundation
import QRCode
import CoreGraphics
import UIKit

public extension QRCode.EyeShape {
    @objc(QRCodeEyeShapeFillCircle) class FillCircle : NSObject, QRCodeEyeShapeGenerator {
        @objc public static let Name: String = "fillCircle"
        @objc public static var Title: String { "FillCircle" }

        @objc static public func Create(_ settings: [String: Any]?) -> QRCodeEyeShapeGenerator {
            return QRCode.EyeShape.FillCircle()
        }

        // Has no configurable settings
        @objc public func settings() -> [String : Any] { return [:] }
        @objc public func supportsSettingValue(forKey key: String) -> Bool { false }
        @objc public func setSettingValue(_ value: Any?, forKey key: String) -> Bool { false }

        /// Make a copy of the object
        @objc public func copyShape() -> QRCodeEyeShapeGenerator {
            return Self.Create(self.settings())
        }

        public func eyePath() -> CGPath {
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 33, y: 33), radius: CGFloat(27), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
            return circlePath.cgPath
        }

        @objc public func eyeBackgroundPath() -> CGPath {
            CGPath(ellipseIn: CGRect(origin: .zero, size: CGSize(width: 66, height: 66)), transform: nil)
        }

        private static let _defaultPupil = QRCode.PupilShape.FillCircle()
        public func defaultPupil() -> QRCodePupilShapeGenerator { Self._defaultPupil }
    }
}


// MARK: - Pupil shape

public extension QRCode.PupilShape {
    /// A circle style pupil design
    @objc(QRCodePupilShapeFillCircle) class FillCircle: NSObject, QRCodePupilShapeGenerator {
        @objc public static var Name: String { "fillCircle" }
        /// The generator title
        @objc public static var Title: String { "FillCircle" }

        @objc public static func Create(_ settings: [String : Any]?) -> QRCodePupilShapeGenerator {
            Circle()
        }

        /// Make a copy of the object
        @objc public func copyShape() -> QRCodePupilShapeGenerator { Circle() }

        @objc public func settings() -> [String : Any] { [:] }
        @objc public func supportsSettingValue(forKey key: String) -> Bool { false }
        @objc public func setSettingValue(_ value: Any?, forKey key: String) -> Bool { false }

        /// The pupil centered in the 90x90 square
        @objc public func pupilPath() -> CGPath {
            return CGPath(ellipseIn: CGRect(x: 21, y: 21, width: 24, height: 24), transform: nil)
        }
    }
}
