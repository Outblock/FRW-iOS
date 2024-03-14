//
//  SpinnerStyle.swift
//  Flow Wallet
//
//  Created by Hao Fu on 2/1/22.
//

import Foundation
import SwiftUI

class SpinnerStyle {
    static let primary: VSpinnerModelContinous = {
        var model: VSpinnerModelContinous = .init()
        model.colors.spinner = Color.LL.orange
        model.layout.dimension = 19
        return model
    }()
}
