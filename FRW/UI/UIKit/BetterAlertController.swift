//
//  BetterAlertController.swift
//  FRW
//
//  Created by cat on 2024/10/17.
//

import UIKit

class BetterAlertController : UIAlertController {

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let screenBounds = UIScreen.main.bounds

        if (preferredStyle == .actionSheet) {
            self.view.center = CGPointMake(screenBounds.size.width*0.5, screenBounds.size.height - (self.view.frame.size.height*0.5) - 8)
        } else {
            self.view.center = CGPointMake(screenBounds.size.width*0.5, screenBounds.size.height*0.5)
        }
    }
}
