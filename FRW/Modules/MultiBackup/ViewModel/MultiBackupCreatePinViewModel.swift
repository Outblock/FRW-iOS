//
//  MultiBackupCreatePinViewModel.swift
//  FRW
//
//  Created by cat on 2024/2/6.
//

import Foundation

class MultiBackupCreatePinViewModel: ObservableObject {
    func onCreate(pin: String) {
        if pin.count == 6 {
            Router.route(to: RouteMap.Backup.confirmPin(pin))
        }
    }
}
