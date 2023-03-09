//
//  Logger.swift
//  Lilico
//
//  Created by Selina on 9/6/2022.
//

import Foundation

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        items.forEach {
            Swift.print($0, separator: separator, terminator: terminator)
        }
    #endif
}

func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        items.forEach {
            Swift.debugPrint($0, separator: separator, terminator: terminator)
        }
    #endif
}
