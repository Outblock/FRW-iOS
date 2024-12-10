//
//  ImportUserNameViewModel.swift
//  FRW
//
//  Created by cat on 2024/9/13.
//

import Foundation

final class ImportUserNameViewModel: ObservableObject {
    // MARK: Lifecycle

    init(callback: @escaping (String) -> Void) {
        self.callback = callback
    }

    // MARK: Internal

    @Published
    var userName: String = ""

    var callback: (String) -> Void

    func onEditingChanged(_: String) {}

    func onConfirm() {
        callback(userName)
        Router.pop()
    }
}
