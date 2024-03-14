//
//  UIImageView.swift
//  Flow Wallet
//
//  Created by Selina on 8/10/2022.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(with url: URL?) {
        self.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))
    }
}
