//
//  BrowserBookmarkViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 10/10/2022.
//

import SwiftUI

class BrowserBookmarkViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        reloadBookmarkList()
    }

    // MARK: Internal

    @Published
    var bookmarkList: [WebBookmark] = []

    func deleteBookmarkAction(_ bookmark: WebBookmark) {
        DBManager.shared.delete(webBookmark: bookmark)
        reloadBookmarkList()
    }

    // MARK: Private

    private func reloadBookmarkList() {
        bookmarkList = DBManager.shared.getAllWebBookmark()
    }
}
