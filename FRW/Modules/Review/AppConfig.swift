//
//  AppConfig.swift
//  FRW
//
//  Created by cat on 2024/7/2.
//

import Foundation

struct AppHide {
    static var FTAdd: ViewVisibility {
        if isChildAccount {
            return .gone
        }
        return ViewVisibility.visible
    }
    
    static var NFTAdd: ViewVisibility {
        if isChildAccount {
            return .gone
        }
        return ViewVisibility.visible
    }
    
    static var swap: ViewVisibility {
        if isChildAccount {
            return .gone
        }
        return ViewVisibility.visible
    }
    
    static var stake: ViewVisibility {
        if isChildAccount {
            return .gone
        }
        return ViewVisibility.visible
    }
    
    static var backup: ViewVisibility {
        if isChildAccount {
            return .gone
        }
        return ViewVisibility.visible
    }
}

extension AppHide {
    static private var isChildAccount: Bool {
        return ChildAccountManager.shared.selectedChildAccount != nil
    }
}
