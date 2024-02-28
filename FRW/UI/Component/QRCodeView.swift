//
//  QRCodeView.swift
//  FRW
//
//  Created by cat on 2023/11/28.
//

import QRCode
import SwiftUI

struct QRCodeView: View {
    var content: String = ""
    var logo: UIImage? = UIImage(named: "lilico-app-icon")
    
    var eyeColor: UIColor?
    
    var body: some View {
        ZStack {
            QRCodeDocumentUIView(document: doc(text: content,
                                               eyeColor: eyeColor ?? (currentNetwork.isMainnet ?
                                                   UIColor.LL.Primary.salmonPrimary : UIColor(hex: "#333333"))))
        }
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(currentNetwork.isMainnet ? Color.LL.Neutrals.background : currentNetwork.color, lineWidth: 1)
                .colorScheme(.light)
        )
        .aspectRatio(1, contentMode: .fit)
    }
    
    func doc(text: String, eyeColor: UIColor) -> QRCode.Document {
        let d = QRCode.Document(generator: QRCodeGenerator_External())
        d.utf8String = text
        if let logo = logo?.cgImage {
            let path = CGPath(ellipseIn: CGRect(x: 0.38, y: 0.38, width: 0.20, height: 0.20), transform: nil)
            d.logoTemplate = QRCode.LogoTemplate(image: logo, path: path, inset: 6)
        }
        
        d.design.backgroundColor(UIColor(hex: "#FAFAFA").cgColor)
        d.design.shape.eye = QRCode.EyeShape.Squircle()
        d.design.style.pupil = QRCode.FillStyle.Solid(eyeColor.cgColor)
        d.design.shape.onPixels = QRCode.PixelShape.Circle(insetFraction: 0.1)
        d.design.style.onPixels = QRCode.FillStyle.Solid(UIColor(hex: "#333333").cgColor)
        return d
    }
}

#Preview {
    QRCodeView(eyeColor: currentNetwork.isMainnet ?
        UIColor.LL.Primary.salmonPrimary : UIColor(hex: "#333333"))
}
