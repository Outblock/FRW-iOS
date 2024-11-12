//
//  ImportUserNameViewModel.swift
//  FRW
//
//  Created by cat on 2024/9/13.
//

import Foundation

class ImportUserNameViewModel: ObservableObject {
    @Published var userName: String = ""

    var callback: (String) -> Void

    init(callback: @escaping (String) -> Void) {
        self.callback = callback
    }

    func onEditingChanged(_: String) {}

    func onConfirm() {
        callback(userName)
        Router.pop()
    }
}
