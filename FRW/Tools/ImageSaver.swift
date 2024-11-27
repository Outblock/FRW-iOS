//
//  ImageSaver.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/11.
//

import Foundation
import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc
    func saveCompleted(
        _: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo _: UnsafeRawPointer
    ) {
        if error != nil {
            print("Save Image Error: \(String(describing: error))")
            HUD.error(title: "error".localized)
        } else {
            HUD.success(title: "saved".localized)
        }
    }
}
