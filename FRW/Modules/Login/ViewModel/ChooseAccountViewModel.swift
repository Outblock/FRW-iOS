//
//  ChooseAccountViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 9/1/22.
//

import SwiftUI

class ChooseAccountViewModel: ObservableObject {
    // MARK: Lifecycle

    init(driveItems: [BackupManager.DriveItem], backupType: BackupManager.BackupType) {
        self.items = driveItems
        self.backupType = backupType
    }

    // MARK: Internal

    @Published
    var items: [BackupManager.DriveItem] = []

    func restoreAccountAction(item: BackupManager.DriveItem) {
        Router.route(to: RouteMap.RestoreLogin.enterRestorePwd(item, backupType))
    }

    // MARK: Private

    private let backupType: BackupManager.BackupType
}
