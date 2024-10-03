//
//  BrowserBookmarkViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 10/10/2022.
//

import SwiftUI

class BrowserBookmarkViewModel: ObservableObject {
    @Published var bookmarkList: [WebBookmark] = []

    init() {
        reloadBookmarkList()
    }

    private func reloadBookmarkList() {
        bookmarkList = DBManager.shared.getAllWebBookmark()
    }

    func deleteBookmarkAction(_ bookmark: WebBookmark) {
        DBManager.shared.delete(webBookmark: bookmark)
        reloadBookmarkList()
    }
}
