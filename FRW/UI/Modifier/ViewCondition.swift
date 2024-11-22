//
//  ViewCondition.swift
//  Flow Wallet
//
//  Created by Hao Fu on 14/9/2022.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    public func `if`<Content: View>(
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
    public func `if`<Value, Content: View>(
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
    public func ifNot<Content: View>(
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
    public func then<Content: View>(@ViewBuilder content: (Self) -> Content) -> some View {
        content(self)
    }
}
