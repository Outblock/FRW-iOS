//
//  AppUpdateManager.swift
//  FlowCore
//
//  Created by cat on 2023/9/1.
//

import Foundation

struct AppUpdateManager {
    // MARK: Lifecycle

    private init() {
        let theKey = "flow_cache_version_key"
        if let currentVersion = Bundle.main
            .infoDictionary?["CFBundleShortVersionString"] as? String {
            if let cacheVersion = UserDefaults.standard.string(forKey: theKey) {
                self.isUpdated = (currentVersion == cacheVersion)
                self.isNowInstall = false
            } else {
                self.isUpdated = true
                self.isNowInstall = true
            }
            UserDefaults.standard.set(currentVersion, forKey: theKey)
        }
    }

    // MARK: Internal

    static let shared = AppUpdateManager()

    var isUpdated: Bool = false
    var isNowInstall: Bool = false
}
