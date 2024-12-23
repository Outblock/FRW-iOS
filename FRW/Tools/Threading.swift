//
//  Threading.swift
//  FRW
//
//  Created by Antonio Bello on 12/2/24.
//

import Foundation

func runOnMain(_ block: @escaping () -> Void) {
    if Thread.current.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
