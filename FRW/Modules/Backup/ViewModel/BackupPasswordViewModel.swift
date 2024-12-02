//
//  BackupPasswordViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 6/1/22.
//

import SPConfetti
import SwiftUI
import UIKit

class BackupPasswordViewModel: ObservableObject {
    // MARK: Lifecycle

    init(backupType: BackupManager.BackupType) {
        self.backupType = backupType

        SPConfettiConfiguration.particlesConfig.colors = [
            Color.LL.Primary.salmonPrimary.toUIColor()!,
            Color.LL.Secondary.mangoNFT.toUIColor()!,
            Color.LL.Secondary.navy4.toUIColor()!,
            Color.LL.Secondary.violetDiscover.toUIColor()!,
        ]
        SPConfettiConfiguration.particlesConfig.velocity = 400
        SPConfettiConfiguration.particlesConfig.velocityRange = 200
        SPConfettiConfiguration.particlesConfig.birthRate = 200
        SPConfettiConfiguration.particlesConfig.spin = 4
    }

    // MARK: Internal

    func backupToCloudAction(password: String) {
        guard let uid = UserManager.shared.activatedUID else { return }

        HUD.loading()

        Task {
            do {
                try await BackupManager.shared.uploadMnemonic(to: backupType, password: password)

                HUD.dismissLoading()

                DispatchQueue.main.async {
                    MultiAccountStorage.shared.setBackupType(self.backupType, uid: uid)

                    if let navi = Router.topNavigationController(),
                       let _ = navi.viewControllers
                       .first(where: { $0.navigationItem.title == "backup".localized }) {
                        Router.route(to: RouteMap.Profile.backupChange)
                    } else {
                        Router.popToRoot()
                        SPConfetti.startAnimating(
                            .fullWidthToDown,
                            particles: [
                                .triangle,
                                .arc,
                                .polygon,
                                .heart,
                                .star,
                            ],
                            duration: 4
                        )
                    }
                }

                HUD
                    .success(
                        title: "backup_to_x_succeeded"
                            .localized(self.backupType.descLocalizedString)
                    )
            } catch {
                HUD.dismissLoading()
                HUD
                    .error(
                        title: "backup_to_x_failed"
                            .localized(self.backupType.descLocalizedString)
                    )
            }
        }
    }

    // MARK: Private

    private var backupType: BackupManager.BackupType
}
