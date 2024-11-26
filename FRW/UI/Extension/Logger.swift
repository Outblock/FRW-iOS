//
//  Logger.swift
//  Flow Wallet
//
//  Created by Selina on 9/6/2022.
//

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    for item in items {
        Swift.print(item, separator: separator, terminator: terminator)
    }
    #endif
}

func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    for item in items {
        Swift.debugPrint(item, separator: separator, terminator: terminator)
    }
    #endif
}
