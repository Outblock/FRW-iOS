//
//  Instabug.swift
//  FRW
//
//  Created by cat on 2024/1/12.
//

import Foundation
import Instabug

class InstabugConfig {
    static func start(token: String) {
        Instabug.start(withToken: token, invocationEvents: [])
        Instabug.trackUserSteps = false
        Instabug.setReproStepsFor(.all, with: .disable)
        Instabug.welcomeMessageMode = .disabled
    }
}
