//
//  ThemeChangeViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 23/5/2022.
//

import Foundation
import SwiftUI

extension ThemeChangeView {
    struct ThemeChangeState {
        var isAuto: Bool
        var isLight: Bool
        var isDark: Bool
    }

    enum ThemeChangeInput {
        case change(ColorScheme?)
    }

    class ThemeChangeViewModel: ViewModel {
        // MARK: Lifecycle

        init() {
            self.state = ThemeChangeState(
                isAuto: ThemeManager.shared.style == nil,
                isLight: ThemeManager.shared.style == .light,
                isDark: ThemeManager.shared.style == .dark
            )
        }

        // MARK: Internal

        @Published
        var state: ThemeChangeState

        func trigger(_ input: ThemeChangeInput) {
            switch input {
            case let .change(cs):
                changeStyle(newStyle: cs)
            }
        }

        // MARK: Private

        private func changeStyle(newStyle: ColorScheme?) {
            DispatchQueue.main.async {
                ThemeManager.shared.setStyle(style: newStyle)
                self.reloadStates()
            }
        }

        private func reloadStates() {
            state = ThemeChangeState(
                isAuto: ThemeManager.shared.style == nil,
                isLight: ThemeManager.shared.style == .light,
                isDark: ThemeManager.shared.style == .dark
            )
        }
    }
}
