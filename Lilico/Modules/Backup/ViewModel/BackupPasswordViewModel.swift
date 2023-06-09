//
//  BackupPasswordViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import SwiftUI
import UIKit
import SPConfetti

class BackupPasswordViewModel: ObservableObject {
    private var backupType: BackupManager.BackupType

    init(backupType: BackupManager.BackupType) {
        self.backupType = backupType
        
        SPConfettiConfiguration.particlesConfig.colors = [ Color.LL.Primary.salmonPrimary.toUIColor()!,
                                                           Color.LL.Secondary.mangoNFT.toUIColor()!,
                                                           Color.LL.Secondary.navy4.toUIColor()!,
                                                           Color.LL.Secondary.violetDiscover.toUIColor()!]
        SPConfettiConfiguration.particlesConfig.velocity = 400
        SPConfettiConfiguration.particlesConfig.velocityRange = 200
        SPConfettiConfiguration.particlesConfig.birthRate = 200
        SPConfettiConfiguration.particlesConfig.spin = 4
    }
    
    func backupToCloudAction(password: String) {
        HUD.loading()
        
        Task {
            do {
                try await BackupManager.shared.uploadMnemonic(to: backupType, password: password)
                
                HUD.dismissLoading()
                
                DispatchQueue.main.async {
                    LocalUserDefaults.shared.backupType = self.backupType
                    
                    if let navi = Router.topNavigationController(),
                       let _ = navi.viewControllers.first(where: { $0.navigationItem.title == "backup".localized }) {
                        Router.route(to: RouteMap.Profile.backupChange)
                    } else {
                        Router.popToRoot()
                        SPConfetti.startAnimating(.fullWidthToDown,
                                                  particles: [.triangle, .arc, .polygon, .heart, .star],
                                                  duration: 4)
                    }
                }
                
                HUD.success(title: "backup_to_x_succeeded".localized(self.backupType.descLocalizedString))
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "backup_to_x_failed".localized(self.backupType.descLocalizedString))
            }
        }
    }
}
