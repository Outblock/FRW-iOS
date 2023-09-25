//
//  NotifyConfiguration.swift
//  FRW
//
//  Created by cat on 2023/9/25.
//

import Foundation
import WalletConnectNotify

class NotifyConfiguration {
    enum Environment: String {
            case debug = "Debug"
            case release = "Release"
        }
        
        static let shared = NotifyConfiguration()
        var environment: Environment
        
        var apnsEnvironment: APNSEnvironment {
            switch environment {
            case .debug:
                return .sandbox
            case .release:
                return .production
            }
        }
        
        init() {
            
            if let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "CONFIGURATION") as? String {
                environment = Environment(rawValue: currentConfiguration)!
            }else {
                environment = .release
            }
        }
}
