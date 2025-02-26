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
            QRCodeDocumentUIView(document: doc(
                text: content,
                eyeColor: eyeColor ?? UIColor.black
            ))
            .padding(12)
        }
        .background(Color.white)
        .cornerRadius(32)
        .aspectRatio(1, contentMode: .fit)
    }

    func doc(text: String, eyeColor: UIColor) -> QRCode.Document {
        let d = QRCode.Document()
        d.utf8String = text
        if let logo = logo?.cgImage {
            let path = CGPath(
                ellipseIn: CGRect(x: 0.38, y: 0.38, width: 0.20, height: 0.20),
                transform: nil
            )
            d.logoTemplate = QRCode.LogoTemplate(image: logo, path: path, inset: 6)
        }

        d.design.backgroundColor(UIColor.white.cgColor)
        d.design.shape.eye = QRCode.EyeShape.Circle()
        d.design.shape.onPixels = QRCode.PixelShape.Circle()

        let color = UIColor.black
        d.design.style.eye = QRCode.FillStyle.Solid(color.cgColor)
        d.design.style.pupil = QRCode.FillStyle.Solid(eyeColor.cgColor)
        d.design.style.onPixels = QRCode.FillStyle.Solid(color.cgColor)
        return d
    }
}

#Preview {
    QRCodeView(content: "abc")
}
