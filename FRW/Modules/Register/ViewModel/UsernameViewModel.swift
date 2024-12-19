//
//  UsernameViewModel.swift
//  Flow Wallet
//
//  Created by Hao Fu on 29/12/21.
//

import Foundation

import SwiftUI

typealias VoidBlock = () -> Void
typealias BoolBlock = (Bool) -> Void

// MARK: - UsernameViewModel

class UsernameViewModel: ViewModel {
    // MARK: Lifecycle

    init(mnemonic: String?) {
        self.state = .init()
        self.mnemonic = mnemonic
    }

    // MARK: Internal

    @Published
    private(set) var state: UsernameView.ViewState

    var lastUpdateTime: Date = .init()
    var task: DispatchWorkItem?
    var currentText: String = ""
    var mnemonic: String?

    func trigger(_ input: UsernameView.Action) {
        switch input {
        case .next:
            registerAction()
            UIApplication.shared.endEditing()
        case let .onEditingChanged(text):
            currentText = text
            if localCheckUserName(text) {
                state.status = .loading()
                task?.cancel()
                task = DispatchWorkItem { [weak self] in
                    self?.checkUsername(text)
                }
                if let work = task {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: work)
                }
            }
        }
    }

    func localCheckUserName(_ username: String) -> Bool {
        if username.count < 3 {
            state.status = .error("too_short".localized)
            return false
        }

        if username.count > 15 {
            state.status = .error("too_long".localized)
            return false
        }

        guard let _ = username.range(of: "^[A-Za-z0-9]{3,15}$", options: .regularExpression) else {
            state.status = .error("username_valid_tips".localized)
            return false
        }

        return true
    }

    func checkUsername(_ username: String) {
        Task {
            do {
                let model: CheckUserResponse = try await Network
                    .request(FRWAPI.User.checkUsername(username.lowercased()))
                await MainActor.run {
                    if model.username == currentText.lowercased() {
                        self.state.status = model
                            .unique ? .success() : .error("has_been_taken".localized)
                    }
                }
            } catch {
                await MainActor.run {
                    self.state.status = .error()
                }
                print(error)
            }
        }
    }

    // MARK: Private

    private func registerAction() {
        state.isRegisting = true

        Task {
            do {
                let txid = try await UserManager.shared.register(currentText)
                let viewModel = CreateProfileWaitingViewModel(txId: txid ?? "") { _, createBackup in

                    DispatchQueue.main.async {
                        self.changeBackupTypeIfNeeded()
                        self.state.isRegisting = false
                        
                        if createBackup {
                            Router.route(to: RouteMap.Backup.rootToBackupList)
                        } else {
                            Router.popToRoot()
                        }
                    }
                }
                Router.route(to: RouteMap.RestoreLogin.createProfile(viewModel))

            } catch {
                DispatchQueue.main.async {
                    self.state.isRegisting = false
                    HUD.error(title: "create_user_failed".localized)
                }
            }
        }
    }

    /// if mnemonic is not nil, means this is a custom mnemonic login, should change the backup type to manual
    private func changeBackupTypeIfNeeded() {
        guard mnemonic != nil else {
            return
        }

        guard let uid = UserManager.shared.activatedUID else { return }
        MultiAccountStorage.shared.setBackupType(.manual, uid: uid)
    }
}
