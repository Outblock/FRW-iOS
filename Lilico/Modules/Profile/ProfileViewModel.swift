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
        case none
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
        var isPushEnabled: Bool = PushHandler.shared.isPushEnabled
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
            
            UserManager.shared.$activatedUID
                .receive(on: DispatchQueue.main)
                .map { $0 }
                .sink { [weak self] activatedUID in
                    self?.refreshBackupState()
                }.store(in: &cancelSets)
            
            NotificationCenter.default.publisher(for: .backupTypeDidChanged)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    self.refreshBackupState()
                }.store(in: &cancelSets)
            
            PushHandler.shared.$isPushEnabled
                .dropFirst()
                .receive(on: DispatchQueue.main)
                .map { $0 }
                .sink { isEnabled in
                    self.state.isPushEnabled = isEnabled
                }.store(in: &cancelSets)
        }

        func trigger(_: ProfileInput) {}
        
        private func refreshBackupState() {
            guard let uid = UserManager.shared.activatedUID else {
                state.backupFetchingState = .none
                return
            }
            
            let backupType = MultiAccountStorage.shared.getBackupType(uid)
            switch backupType {
            case .manual:
                state.backupFetchingState = .manually
                return
            case .none:
                state.backupFetchingState = .none
                return
            default:
                break
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
    
    func showSwitchProfileAction() {
        Router.route(to: RouteMap.Profile.switchProfile)
    }
    
    func showSystemSettingAction() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    PushHandler.shared.requestPermission()
                } else {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}
