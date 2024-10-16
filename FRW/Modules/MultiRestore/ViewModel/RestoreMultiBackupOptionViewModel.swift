//
//  RestoreMultiBackupOptionViewModel.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import Foundation

class RestoreMultiBackupOptionViewModel: ObservableObject {
    @Published var list: [BackupMultiViewModel.MultiItem] = []
    @Published var nextable: Bool = false

    init() {
        for type in MultiBackupType.allCases {
            if type != .passkey {
                list.append(BackupMultiViewModel.MultiItem(type: type, isBackup: false))
            }
        }
    }

    func onClick(item: BackupMultiViewModel.MultiItem) {
        list = list.map { model in
            var model = model
            if model.type == item.type {
                model.isBackup = !model.isBackup
            }
            return model
        }
        nextable = waitingList().count >= 2
    }

    func waitingList() -> [MultiBackupType] {
        let waiting = list.filter { $0.isBackup }
        return waiting.map { $0.type }
    }

    func onNext() {
        let list = waitingList()
        Router.route(to: RouteMap.RestoreLogin.multiConnect(list))
    }
}
