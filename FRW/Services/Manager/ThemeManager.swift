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
        reloadStyle()
    }

    // MARK: Internal

    static let shared = ThemeManager()

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

        return .dark
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
