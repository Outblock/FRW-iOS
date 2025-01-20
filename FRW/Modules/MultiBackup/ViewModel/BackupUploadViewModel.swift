//
//  BackupUploadViewModel.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import Foundation
import SwiftUI

// MARK: - BackupProcess

enum BackupProcess {
    case idle, upload, regist, finish, end

    // MARK: Internal

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
    // MARK: Lifecycle

    init(items: [MultiBackupType]) {
        self.items = items
        self.currentIndex = 0
        if !self.items.isEmpty {
            self.currentType = self.items[0]
        }
        if currentType == .phrase {
            self.buttonState = .disabled
        }
    }

    // MARK: Internal

    let items: [MultiBackupType]

    @Published
    var process: BackupProcess = .idle
    @Published
    var hasError: Bool = false
    @Published
    var mnemonicBlur: Bool = true

    var currentType: MultiBackupType = .google
    @Published
    var buttonState: VPrimaryButtonState = .enabled

    @Published
    var currentIndex: Int = 0 {
        didSet {
            if currentIndex < items.count {
                currentType = items[currentIndex]
            }
        }
    }

    // TODO:
    @Published
    var checkAllPhrase: Bool = true {
        didSet {
            if checkAllPhrase {
                buttonState = .enabled
            }
        }
    }

    // MARK: UI element

    var currentIcon: String {
        switch currentType {
        case .google:
            return "icon.google.drive"
        case .passkey:
            return "icon.passkey"
        case .icloud:
            return "Icloud"
        case .phrase:
            return "icon.recovery"
        case .dropbox:
            return "icon.dropbox.circle.64"
        }
    }

    var currentTitle: String {
        switch process {
        case .idle:
            return "backup".localized + " \(currentIndex + 1):\(currentType.title) " + "backup"
                .localized
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
        if process == .upload, hasError {
            return "upload_again".localized
        }
        return process.title
    }

    func reset() {
        hasError = false
        process = .idle
    }

    func showTimeline() -> Bool {
        process == .upload || process == .regist
    }

    func learnMore() {
        let closure = {}
        Router.route(to: RouteMap.Backup.introduction(.aboutRecoveryPhrase, closure, true))
    }

    func onClickButton() {
        handleProcess(process: process)
    }

    func handleProcess(process: BackupProcess) {
        hasError = false
        self.process = process
        switch process {
        case .idle:
            Task {
                do {
                    DispatchQueue.main.async {
                        self.buttonState = .loading
                        self.mnemonicBlur = true
                    }
                    try await MultiBackupManager.shared.preLogin(with: currentType)
                    let result = try await MultiBackupManager.shared
                        .registerKeyToChain(on: currentType)
                    if result {
                        runOnMain {
                            self.handleProcess(process: .upload)
                        }
                    } else {
                        runOnMain {
                            self.buttonState = .enabled
                        }
                        HUD.error(title: "create error on chain")
                    }
                } catch {
                    runOnMain {
                        self.buttonState = .enabled
                    }
                    trackCreatFailed(message: "idle:" + error.localizedDescription)
                }
            }
        case .upload:
            Task {
                do {
                    runOnMain {
                        self.buttonState = .loading
                    }

                    try await MultiBackupManager.shared.backupKey(on: currentType)
                    runOnMain {
                        self.handleProcess(process: .regist)
                    }
                } catch {
                    runOnMain {
                        self.buttonState = .enabled
                        self.hasError = true
                    }
                    log.error(error)
                    trackCreatFailed(message: "upload:" + error.localizedDescription)
                }
            }
        case .regist:
            Task {
                do {
                    runOnMain {
                        self.buttonState = .loading
                    }
                    try await MultiBackupManager.shared.syncKeyToServer(on: currentType)
                    runOnMain {
                        self.mnemonicBlur = false
                        self.buttonState = .enabled
                        self.process = .finish
                    }
                    trackCreatSuccess()

                } catch {
                    runOnMain {
                        self.buttonState = .enabled
                    }
                    HUD.dismissLoading()
                    log.error(error)
                    trackCreatFailed(message: "register:" + error.localizedDescription)
                }
            }
        case .finish:
            let nextIndex = currentIndex + 1
            if items.count <= nextIndex {
                currentIndex = nextIndex
                self.process = .end
            } else {
                currentIndex = nextIndex
                self.process = .idle
            }
        case .end:
            Router.popToRoot()
        }
    }
}

extension BackupUploadViewModel {
    private func trackSource() -> String {
        currentType.methodName()
    }

    func trackCreatSuccess() {
        EventTrack.Backup.multiCreated(source: trackSource())
    }

    func trackCreatFailed(message: String) {
        EventTrack.Backup
            .multiCreatedFailed(source: trackSource(), reason: message)
    }
}
