//
//  BetterAlertController.swift
//  FRW
//
//  Created by cat on 2024/10/17.
//

import UIKit

class BetterAlertController: UIAlertController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let screenBounds = UIScreen.main.bounds

        if preferredStyle == .actionSheet {
            view.center = CGPointMake(
                screenBounds.size.width * 0.5,
                screenBounds.size.height - (view.frame.size.height * 0.5) - 8
            )
        } else {
            view.center = CGPointMake(screenBounds.size.width * 0.5, screenBounds.size.height * 0.5)
        }
    }
}
