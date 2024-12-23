//
//  DispatchQueue.swift
//  Flow Wallet
//
//  Created by Selina on 5/8/2022.
//

import SwiftUI
import UIKit

extension DispatchQueue {
    static func syncOnMain(_ callback: @escaping () -> Void) {
        if Thread.isMainThread {
            callback()
        } else {
            DispatchQueue.main.async {
                callback()
            }
        }
    }
}
