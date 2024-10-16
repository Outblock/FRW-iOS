//
//  ShareItem.swift
//  Flow Wallet
//
//  Created by Hao Fu on 6/9/2022.
//

import Foundation
import LinkPresentation
import UIKit

class ShareActivityItemSource: NSObject, UIActivityItemSource {
    var shareText: String
    var shareImage: UIImage
    var linkMetaData = LPLinkMetadata()

    init(shareText: String, shareImage: UIImage) {
        self.shareText = shareText
        self.shareImage = shareImage
        linkMetaData.title = shareText
        linkMetaData.imageProvider = NSItemProvider(object: shareImage)
        super.init()
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return UIImage(named: "AppIcon") as Any
    }

    func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetaData
    }
}
