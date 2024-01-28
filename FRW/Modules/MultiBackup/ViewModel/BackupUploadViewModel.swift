//
//  BackupUploadViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import Foundation
import SwiftUI

enum BackupProcess {
    case idle, upload, regist, finish, end
    
    var title: String {
        switch self {
        case .idle:
            "backup.status.create".localized
        case .upload:
            "backup.status.upload".localized
        case .regist:
            "backup.status.regist".localized
        case .finish:
            "backup.status.finish".localized
        case .end:
            "backup.status.end".localized
        }
    }
    
    var icon: String {
        switch self {
        case .finish:
            return "backup.status.finish"
        default:
            return ""
        }
    }
    
    var next: BackupProcess {
        switch self {
        case .idle:
            return .upload
        case .upload:
            return .regist
        case .regist:
            return .finish
        case .finish:
            return .idle
        case .end:
            return .end
        }
    }
}

// MARK: - BackupUploadViewModel

class BackupUploadViewModel: ObservableObject {
    let items: [MultiBackupType]
    
    @Published var currentIndex: Int = 0 {
        didSet {
            if currentIndex < items.count {
                currentType = items[currentIndex]
            }
        }
    }

    @Published var process: BackupProcess = .idle
    @Published var hasError: Bool = false
    
    var currentType: MultiBackupType = .google
    init(items: [MultiBackupType]) {
        self.items = items
        currentIndex = 0
        if !self.items.isEmpty {
            currentType = self.items[0]
        }
    }
    
    func reset() {
        hasError = false
        process = .idle
    }
    
    // MARK: UI element

    var currentIcon: String {
        currentType.iconName()
    }
    
    var currentTitle: String {
        switch process {
        case .idle:
            return "backup".localized + " \(currentIndex + 1):\(currentType.title) " + "backup".localized
        case .upload:
            return "backup.status.upload".localized
        case .regist:
            return "backup.status.upload".localized
        case .finish:
            return "backup.status.finish.title".localized
        case .end:
            return "backup.status.end.title".localized
        }
    }
    
    var currentNote: String {
        currentType.noteDes
    }
    
    var currentButton: String {
        if process == .upload && hasError {
            return "upload_again".localized
        }
        return process.title
    }
    
    func showTimeline() -> Bool {
        return process == .upload || process == .regist
    }
    
    func onClickButton() {
        switch process {
        case .idle:
            Task {
                do {
                    try await MultiBackupManager.shared.login(from: currentType)
                    HUD.loading()
                    let result = try await MultiBackupManager.shared.registerKeyToChain(on: currentType)
                    HUD.dismissLoading()
                    if result {
                        toggleProcess(process: .upload)
                    } else {
                        HUD.error(title: "create error on chain")
                    }
                } catch {
                    HUD.dismissLoading()
                }
            }
        case .upload:
            Task {
                do {
                    HUD.loading()
                    try await MultiBackupManager.shared.backupKey(on: currentType)
                    toggleProcess(process: .regist)
                    HUD.dismissLoading()
                } catch {
                    HUD.dismissLoading()
                    hasError = true
                    log.error(error)
                }
            }
        case .regist:
            Task {
                do {
                    HUD.loading()
                    try await MultiBackupManager.shared.syncKeyToServer(on: currentType)
                    toggleProcess(process: .finish)
                    HUD.dismissLoading()
                } catch {
                    HUD.dismissLoading()
                    log.error(error)
                }
            }
        case .finish:
            let nextIndex = currentIndex + 1
            if items.count <= nextIndex {
                currentIndex = nextIndex
                toggleProcess(process: .end)
            } else {
                currentIndex = nextIndex
                toggleProcess(process: .idle)
            }
        case .end:
            Router.popToRoot()
        }
    }
    
    func toggleProcess(process: BackupProcess) {
        self.process = process
//        switch self.process {
//        case .idle:
//            <#code#>
//        case .upload:
//            <#code#>
//        case .regist:
//            <#code#>
//        case .finish:
//            <#code#>
//        }
    }
}
