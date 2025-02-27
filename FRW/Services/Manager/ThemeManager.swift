//
//  ThemeManager.swift
//  Flow Wallet
//
//  Created by Selina on 17/5/2022.
//

import Foundation
import SwiftUI

// MARK: - ThemeManager

class ThemeManager: ObservableObject {
    // MARK: Lifecycle

    init() {
        if userDefaultTheme {
            setStyle(style: .dark)
            self.userDefaultTheme = false
        }
        reloadStyle()
    }

    // MARK: Internal

    static let shared = ThemeManager()

    @AppStorage(LocalUserDefaults.Keys.userDefaultTheme.rawValue)
    var userDefaultTheme: Bool = true

    @Published
    var style: ColorScheme?

    func setStyle(style: ColorScheme?) {
        if let style = style {
            storageThemeKey = style.key
        } else {
            storageThemeKey = nil
        }

        reloadStyle()
    }

    func getUIKitStyle() -> UIUserInterfaceStyle {
        if let style = style {
            return style.toUIKitEnum
        }
        // if auto, style is setted by system
        let systemStyle = UIScreen.main.traitCollection.userInterfaceStyle
        return systemStyle == .light ? .light : .dark
    }

    func updateStyle(style: UIUserInterfaceStyle) {
        guard self.style == nil else {
            log.debug("[Theme] not changed")
            return
        }
        log.debug("[Theme] auto")
        setStyle(style: nil)
    }

    // MARK: Private

    @AppStorage("customThemeKey")
    private var storageThemeKey: String?

    private func reloadStyle() {
        style = ColorScheme.fromKey(key: storageThemeKey)
    }
}

extension ColorScheme {
    var key: String {
        switch self {
        case .light:
            return "light"
        case .dark:
            return "dark"
        @unknown default:
            return "dark"
        }
    }

    var desc: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return "Dark"
        }
    }

    var toUIKitEnum: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return .dark
        }
    }

    static func fromKey(key: String?) -> ColorScheme? {
        guard let key = key else {
            return nil
        }

        switch key {
        case ColorScheme.light.key:
            return ColorScheme.light
        case ColorScheme.dark.key:
            return ColorScheme.dark
        default:
            return nil
        }
    }
}
