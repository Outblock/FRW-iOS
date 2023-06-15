//
//  ProfileBackupViewModel.swift
//  Lilico
//
//  Created by Selina on 2/8/2022.
//

import SwiftUI
import Combine

class ProfileBackupViewModel: ObservableObject {
    @Published var selectedBackupType: BackupManager.BackupType = .none
    
    private var cancelSets = Set<AnyCancellable>()
    
    init() {
        if let uid = UserManager.shared.activatedUID {
            self.selectedBackupType = MultiAccountStorage.shared.getBackupType(uid)
        }
        
        NotificationCenter.default.publisher(for: .backupTypeDidChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.refreshBackupType()
            }.store(in: &cancelSets)
    }
    
    private func refreshBackupType() {
        if let uid = UserManager.shared.activatedUID {
            self.selectedBackupType = MultiAccountStorage.shared.getBackupType(uid)
        } else {
            self.selectedBackupType = .none
        }
    }
    
    func changeBackupTypeAction(_ type: BackupManager.BackupType) {
        guard let uid = UserManager.shared.activatedUID else { return }
        
        let oldBackupType = MultiAccountStorage.shared.getBackupType(uid)
        
        if oldBackupType == type {
            selectedBackupType = type
            return
        }
        
        if type == .manual {
            MultiAccountStorage.shared.setBackupType(.manual, uid: uid)
            return
        }
        
        let backupCloudBlock: ((BackupManager.BackupType) -> Void) = { type in
            DispatchQueue.main.async {
                HUD.dismissLoading()
                Router.route(to: RouteMap.Backup.backupToCloud(type))
            }
        }
        
        HUD.loading("loading".localized)
        
        Task {
            do {
                let exist = try await BackupManager.shared.isExistOnCloud(type)
                if exist {
                    HUD.dismissLoading()
                    DispatchQueue.main.async {
                        MultiAccountStorage.shared.setBackupType(type, uid: uid)
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
