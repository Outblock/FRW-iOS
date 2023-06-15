//
//  ChildAccountManager.swift
//  Lilico
//
//  Created by Selina on 15/6/2023.
//

import Foundation

class ChildAccountManager {
    static let shared = ChildAccountManager()
    private init() {
        
    }
    
    func startLink() {
        Router.route(to: RouteMap.Explore.linkChildAccount)
    }
}
