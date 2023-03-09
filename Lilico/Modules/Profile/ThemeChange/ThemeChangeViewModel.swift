//
//  ThemeChangeViewModel.swift
//  Lilico
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
        @Published var state: ThemeChangeState

        init() {
            state = ThemeChangeState(isAuto: ThemeManager.shared.style == nil,
                                     isLight: ThemeManager.shared.style == .light,
                                     isDark: ThemeManager.shared.style == .dark)
        }

        func trigger(_ input: ThemeChangeInput) {
            switch input {
            case let .change(cs):
                changeStyle(newStyle: cs)
            }
        }

        private func changeStyle(newStyle: ColorScheme?) {
            DispatchQueue.main.async {
                ThemeManager.shared.setStyle(style: newStyle)
                self.reloadStates()
            }
        }

        private func reloadStates() {
            state = ThemeChangeState(isAuto: ThemeManager.shared.style == nil,
                                     isLight: ThemeManager.shared.style == .light,
                                     isDark: ThemeManager.shared.style == .dark)
        }
    }
}
