//
//  BackupSelectOptionsViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/7.
//

import Foundation

class BackupMultiViewModel: ObservableObject {
    @Published var list: [BackupMultiViewModel.MultiItem] = []
    @Published var nextable: Bool = false
    let selectedList: [MultiBackupType]
    
    init(backups: [MultiBackupType]) {
        list = []
        selectedList = backups
        for type in MultiBackupType.allCases {
            if type != .passkey {
                list.append(MultiItem(type: type, isBackup: backups.contains(type)))
            }
        }
    }
    
    func onClick(item: BackupMultiViewModel.MultiItem) {
        let existItem = selectedList.first { $0 == item.type }
        guard existItem == nil else { return }
        list = list.map { model in
            var model = model
            if model.type == item.type {
                model.isBackup = !model.isBackup
            }
            return model
        }
        nextable = (selectedList.count + waitingList().count) >= 2
    }
    
    func waitingList() -> [MultiBackupType] {
        var waiting = list.filter { $0.isBackup }
        waiting = waiting.filter { !selectedList.contains($0.type) }
        return waiting.map { $0.type }
    }
    
    func onNext() {
        MultiBackupManager.shared.backupList = []
        let list = waitingList()
        let needPin = list.filter { $0.needPin }
        let hasPin = SecurityManager.shared.currentPinCode.count > 0
        MultiBackupManager.shared.backupList = list
        if needPin.count > 0 {
            if hasPin {
                Router.route(to: RouteMap.Backup.verityPin(.backup) { allow, _ in
                    if allow {
                        Router.route(to: RouteMap.Backup.uploadMulti(list))
                    }
                })
            } else {
                Router.route(to: RouteMap.Backup.createPin)
            }
        } else {
            Router.route(to: RouteMap.Backup.uploadMulti(list))
        }
    }
}

// MARK: - MultiItem

enum MultiBackupType: Int, CaseIterable {
    case google = 0
    case passkey = 1
    case icloud = 2
    case phrase = 3
    
    var title: String {
        switch self {
        case .google:
            return "google_drive".localized
        case .passkey:
            return "Passkey"
        case .icloud:
            return "iCloud"
        case .phrase:
            return "Recovery Phrase"
        }
    }
    
    func iconName() -> String {
        switch self {
        case .google:
            return "icon.google.drive"
        case .passkey:
            return "icon.passkey"
        case .icloud:
            return "Icloud"
        case .phrase:
            return "icon.recovery"
        }
    }
    
    var noteDes: String {
        "backup_note_x".localized
    }
    
    var normalIcon: String {
        switch self {
        case .google:
            return "Google.Drive.normal"
        case .passkey:
            return "icon.passkey.normal"
        case .icloud:
            return "Icloud.normal"
        case .phrase:
            return "icon.recovery.normal"
        }
    }
    
    var highlightIcon: String {
        switch self {
        case .google:
            return "Google.Drive.highlight"
        case .passkey:
            return "icon.passkey.highlight"
        case .icloud:
            return "Icloud.highlight"
        case .phrase:
            return "icon.recovery.highlight"
        }
    }
    
    var needPin: Bool {
        switch self {
        case .google, .icloud:
            return true
        default:
            return false
        }
    }
}

extension BackupMultiViewModel {
    struct MultiItem: Hashable {
        let type: MultiBackupType
        var isBackup: Bool
        
        var name: String {
            type.title
        }
        
        var icon: String {
            return type.iconName()
        }
    }
}

extension MultiBackupType {
    func toBackupType() -> BackupType {
        switch self {
        case .google:
            return .google
        case .passkey:
            return .passkey
        case .icloud:
            return .iCloud
        case .phrase:
            return .manual
        }
    }
    
    func showName() -> String {
        let type = toBackupType()
        return "backup".localized + " - " + type.title
    }
}
