//
//  ChooseAccountViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 9/1/22.
//

import SwiftUI

class ChooseAccountViewModel: ObservableObject {
    @Published var items: [BackupManager.DriveItem] = []
    private let backupType: BackupManager.BackupType

    init(driveItems: [BackupManager.DriveItem], backupType: BackupManager.BackupType) {
        items = driveItems
        self.backupType = backupType
    }

    func restoreAccountAction(item: BackupManager.DriveItem) {
        Router.route(to: RouteMap.RestoreLogin.enterRestorePwd(item, backupType))
    }
}
