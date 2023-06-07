//
//  TYNKViewModel.swift
//  Lilico
//
//  Created by Hao Fu on 3/1/22.
//

import Foundation
import SwiftUI


class TYNKViewModel: ObservableObject {
    func chooseBackupMethodAction() {
        Router.route(to: RouteMap.Backup.chooseBackupMethod)
    }
}
