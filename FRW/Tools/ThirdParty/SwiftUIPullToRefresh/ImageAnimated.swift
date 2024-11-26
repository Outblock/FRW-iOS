//
//  ImageAnimated.swift
//  Flow Wallet
//
//  Created by Selina on 8/9/2022.
//

import SnapKit
import SwiftUI

extension ImageAnimated {
    static func appRefreshImageNames() -> [String] {
        var images: [String] = []
        for i in 0...95 {
            images.append("refresh-header-seq-\(i)")
        }

        return images
    }
}

// MARK: - ImageAnimated

struct ImageAnimated: UIViewRepresentable {
    // MARK: Internal

    let imageSize: CGSize
    let imageNames: [String]
    let duration: Double
    var isAnimating: Bool = false

    func makeUIView(context _: Self.Context) -> UIView {
        let containerView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: imageSize.width,
            height: imageSize.height
        ))

        let animationImageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: imageSize.width,
            height: imageSize.height
        ))

        animationImageView.clipsToBounds = true
        animationImageView.contentMode = UIView.ContentMode.scaleAspectFill

        animationImageView.animationImages = generateImages()
        animationImageView.animationDuration = duration

        containerView.addSubview(animationImageView)
        animationImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(imageSize.width)
            make.height.equalTo(imageSize.height)
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context _: UIViewRepresentableContext<ImageAnimated>) {
        guard let imageView = uiView.subviews.first as? UIImageView else {
            return
        }

        if isAnimating {
            imageView.startAnimating()
        } else {
            imageView.stopAnimating()
            imageView.image = generateImages().first
        }
    }

    // MARK: Private

    private func generateImages() -> [UIImage] {
        var images = [UIImage]()
        for imageName in imageNames {
            if let img = UIImage(named: imageName) {
                images.append(img)
            }
        }

        return images
    }
}
