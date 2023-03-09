//
//  ProfileViewModel.swift
//  Lilico
//
//  Created by Selina on 23/5/2022.
//

import Combine
import Foundation
import SwiftUI

extension ProfileView {
    enum BackupFetchingState {
        case manually
        case fetching
        case failed
        case synced
    }
    
    struct ProfileState {
        var isLogin: Bool = false
        var currency: String = CurrencyCache.cache.currentCurrency.rawValue
        var colorScheme: ColorScheme?
        var backupFetchingState: BackupFetchingState = .manually
    }

    enum ProfileInput {}

    class ProfileViewModel: ViewModel {
        @Published var state = ProfileState()

        private var cancelSets = Set<AnyCancellable>()

        let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        init() {
            state.colorScheme = ThemeManager.shared.style
            
            CurrencyCache.cache.$currentCurrency.sink { currency in
                DispatchQueue.main.async {
                    self.state.currency = currency.rawValue
                }
            }.store(in: &cancelSets)

            ThemeManager.shared.$style.sink(receiveValue: { [weak self] newScheme in
                self?.state.colorScheme = newScheme
            }).store(in: &cancelSets)
            
            UserManager.shared.$isLoggedIn.sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.refreshBackupState()
                }
            }.store(in: &cancelSets)
            
            NotificationCenter.default.publisher(for: .backupTypeDidChanged).sink { _ in
                DispatchQueue.main.async {
                    self.refreshBackupState()
                }
            }.store(in: &cancelSets)
        }

        func trigger(_: ProfileInput) {}
        
        private func refreshBackupState() {
            if !UserManager.shared.isLoggedIn {
                state.backupFetchingState = .manually
                return
            }
            
            let backupType = LocalUserDefaults.shared.backupType
            if backupType == .manual {
                state.backupFetchingState = .manually
                return
            }
            
            state.backupFetchingState = .fetching
            
            Task {
                do {
                    let exist = try await BackupManager.shared.isExistOnCloud(backupType)
                    DispatchQueue.main.async {
                        self.state.backupFetchingState = exist ? .synced : .failed
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.state.backupFetchingState = .failed
                    }
                }
            }
        }
    }
}

extension ProfileView.ProfileViewModel {
    func securityAction() {
        if SecurityManager.shared.securityType == .none {
            Router.route(to: RouteMap.Profile.security(true))
            return
        }
        
        Task {
            let result = await SecurityManager.shared.inAppVerify()
            if result {
                Router.route(to: RouteMap.Profile.security(false))
            }
        }
    }
}
