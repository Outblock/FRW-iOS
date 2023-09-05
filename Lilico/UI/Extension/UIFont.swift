//
//  UIFont.swift
//  Lilico
//
//  Created by Selina on 19/5/2022.
//

import UIKit

extension UIFont {
    var bold: UIFont { return withWeight(.bold) }
    var semibold: UIFont { return withWeight(.semibold) }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        var traits = (attributes[.traits] as? [UIFontDescriptor.TraitKey: Any]) ?? [:]

        traits[.weight] = weight

        attributes[.name] = nil
        attributes[.traits] = traits
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

// ["Inter-Regular", "Inter-Regular_Italic", "Inter-Regular_Thin", "Inter-Regular_Thin-Italic", "Inter-Regular_ExtraLight", "Inter-Regular_ExtraLight-Italic", "Inter-Regular_Light", "Inter-Regular_Light-Italic", "Inter-Regular_Medium", "Inter-Regular_Medium-Italic", "Inter-Regular_SemiBold", "Inter-Regular_SemiBold-Italic", "Inter-Regular_Bold", "Inter-Regular_Bold-Italic", "Inter-Regular_ExtraBold", "Inter-Regular_ExtraBold-Italic", "Inter-Regular_Black", "Inter-Regular_Black-Italic"]

// Montserrat Font names: ["Montserrat-Regular", "Montserrat-Italic", "Montserrat-Bold"]

extension UIFont {
    static func interMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Medium", size: size)!
    }
    
    static func interSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Bold", size: size)!
    }
    
    static func interBold(size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Bold", size: size)!
    }
    
    static func inter(size: CGFloat) -> UIFont {
        return UIFont(name: "e-Ukraine-Regular", size: size)!
    }
    
    static func montserratBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Montserrat-Bold", size: size)!
    }
}
