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
            currentType = items[currentIndex]
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
    
    // MARK: backup on Goodle Drive
    
    func prepareGoodle() {}
    
    func onClickButton() {
        switch process {
        case .idle:
            Task {
                do {
                    try await MultiBackupManager.shared.login(from: currentType)
                    toggleProcess(process: .upload)
                } catch {}
            }
        case .upload:
            Task {
                do {
                    HUD.loading()
                    try await MultiBackupManager.shared.uploadPublicKey(to: currentType)
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
                    try await MultiBackupManager.shared.syncDeviceToService()
                    toggleProcess(process: .finish)
                    HUD.dismissLoading()
                } catch {
                    HUD.dismissLoading()
                    log.error(error)
                }
            }
            log.info("not suport")
        case .finish:
            let nextIndex = currentIndex + 1
            if items.count <= nextIndex {
                toggleProcess(process: .end)
            } else {
                currentIndex = nextIndex
                toggleProcess(process: .idle)
            }
            log.info("not suport")
        case .end:
            log.info("not suport")
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
