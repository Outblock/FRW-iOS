//
//  UIImageView.swift
//  Flow Wallet
//
//  Created by Selina on 8/10/2022.
//

import Kingfisher
import UIKit

extension UIImageView {
    func setImage(with url: URL?) {
        kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
    }
}
