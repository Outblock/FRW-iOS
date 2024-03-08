//
//  Keyboard.swift
//  Flow Wallet
//
//  Created by Hao Fu on 3/1/22.
//

import Combine
import Foundation
import SwiftUI

#if canImport(UIKit)
    extension View {
        func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif

public extension View {
    func dismissKeyboardOnDrag() -> some View {
        gesture(DragGesture().onChanged { _ in self.dismissKeyboard() })
    }
}

extension View {
    func numberOnly(text: Binding<String>) -> some View {
        modifier(NumberOnlyViewModifier(text: text))
    }
}

public struct NumberOnlyViewModifier: ViewModifier {
    @Binding var text: String

    public init(text: Binding<String>) {
        _text = text
    }

    public func body(content: Content) -> some View {
        content
            .keyboardType(.numberPad)
            .onReceive(Just(text)) { newValue in
                let filtered = newValue.filter { "0123456789".contains($0) }
                if filtered != newValue {
                    self.text = filtered
                }
            }
    }
}
