//
//  Mock.swift
//  Flow Wallet
//
//  Created by Selina on 30/6/2023.
//

import Foundation

protocol Mockable {
    static func mock() -> Self
}

extension Array where Element: Mockable {
    static func mock(_ num: Int = 3) -> Self {
        var array = [Element]()
        for _ in 0..<num {
            array.append(Element.mock())
        }
        
        return array
    }
}


func randomString(_ num: Int = 6) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var randomString = ""
    for _ in 0..<num {
        let randomValue = arc4random_uniform(UInt32(letters.count))
        let randomIndex = letters.index(letters.startIndex, offsetBy: Int(randomValue))
        let randomLetter = letters[randomIndex]
        randomString.append(randomLetter)
    }
    return randomString
}
