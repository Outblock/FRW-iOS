//
//  ConfettiManager.swift
//  FRW
//
//  Created by cat on 2024/4/11.
//

import SwiftUI
import SPConfetti

struct ConfettiManager {
    static func `default`() {
        SPConfettiConfiguration.particlesConfig.colors = [ Color.LL.Primary.salmonPrimary.toUIColor()!,
                                                           Color.LL.Secondary.mangoNFT.toUIColor()!,
                                                           Color.LL.Secondary.navy4.toUIColor()!,
                                                           Color.LL.Secondary.violetDiscover.toUIColor()!]
        SPConfettiConfiguration.particlesConfig.velocity = 400
        SPConfettiConfiguration.particlesConfig.velocityRange = 200
        SPConfettiConfiguration.particlesConfig.birthRate = 200
        SPConfettiConfiguration.particlesConfig.spin = 4
    }
    
    static func show() {
        DispatchQueue.main.async {
            ConfettiManager.default()
            SPConfetti.startAnimating(.fullWidthToDown,
                                      particles: [.triangle, .arc, .polygon, .heart, .star],
                                      duration: 4)
        }
    }
}
