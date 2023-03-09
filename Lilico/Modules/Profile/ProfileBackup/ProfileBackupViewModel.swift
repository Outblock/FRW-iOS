//
//  ProfileBackupViewModel.swift
//  Lilico
//
//  Created by Selina on 2/8/2022.
//

import SwiftUI
import Combine

class ProfileBackupViewModel: ObservableObject {
    @Published var selectedBackupType: BackupManager.BackupType = LocalUserDefaults.shared.backupType
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: .backupTypeDidChanged).sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshBackupType()
            }
        }.store(in: &cancelSets)
    }
    
    private func refreshBackupType() {
        selectedBackupType = LocalUserDefaults.shared.backupType
    }
    
    func changeBackupTypeAction(_ type: BackupManager.BackupType) {
        if LocalUserDefaults.shared.backupType == type {
            selectedBackupType = type
            return
        }
        
        if type == .manual {
//            Router.route(to: RouteMap.Profile.manualBackup)
            LocalUserDefaults.shared.backupType = .manual
            return
        }
        
        let backupCloudBlock: ((BackupManager.BackupType) -> Void) = { type in
            HUD.dismissLoading()
            Router.route(to: RouteMap.Backup.backupToCloud(type))
        }
        
        HUD.loading("loading".localized)
        
        Task {
            do {
                let exist = try await BackupManager.shared.isExistOnCloud(type)
                if exist {
                    HUD.dismissLoading()
                    DispatchQueue.main.async {
                        LocalUserDefaults.shared.backupType = type
                    }
                    return
                }
                
                backupCloudBlock(type)
            } catch BackupError.fileIsNotExistOnCloud {
                // icloud file is not exist, it's ok
                backupCloudBlock(type)
            } catch {
                HUD.dismissLoading()
                HUD.error(title: "backup_to_x_failed".localized(type.descLocalizedString))
            }
        }
    }
}
