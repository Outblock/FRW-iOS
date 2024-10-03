//
//  ViewCondition.swift
//  Flow Wallet
//
//  Created by Hao Fu on 14/9/2022.
//

import Foundation
import SwiftUI

public extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: @autoclosure @escaping () -> Bool,
        @ViewBuilder content: (Self) -> Content
    ) -> some View {
        if condition() {
            content(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<Value, Content: View>(
        `let` value: Value?,
        @ViewBuilder content: (_ view: Self, _ value: Value) -> Content
    ) -> some View {
        if let value = value {
            content(self, value)
        } else {
            self
        }
    }

    @ViewBuilder
    func ifNot<Content: View>(
        _ notCondition: @autoclosure @escaping () -> Bool,
        @ViewBuilder content: (Self) -> Content
    ) -> some View {
        if notCondition() {
            self
        } else {
            content(self)
        }
    }

    @ViewBuilder
    func then<Content: View>(@ViewBuilder content: (Self) -> Content) -> some View {
        content(self)
    }
}
