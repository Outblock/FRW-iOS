//
//  ProfileEditNameViewModel.swift
//  Flow Reference Wallet
//
//  Created by Selina on 14/6/2022.
//

import Alamofire

import SwiftUI

extension ProfileEditNameViewModel {
    enum Input {
        case save
    }

    enum StatusType {
        case idle
        case ok
    }
}

class ProfileEditNameViewModel: ObservableObject {
    @Published var name: String = "" {
        didSet {
            refreshStatus()
        }
    }

    @Published var status: StatusType = .idle

    init() {
        name = UserManager.shared.userInfo?.nickname ?? ""
    }

    private func refreshStatus() {
        let name = name.trim()
        if name.isEmpty || name == UserManager.shared.userInfo?.nickname {
            status = .idle
            return
        }

        status = .ok
    }

    func trigger(_ input: Input) {
        switch input {
        case .save:
            save()
        }
    }

    private func save() {
        HUD.loading("saving".localized)

        let name = name.trim()
        let avatar = UserManager.shared.userInfo?.avatar ?? ""

        let success = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                UserManager.shared.updateNickname(name)
                Router.pop()
            }
        }

        let failed = {
            DispatchQueue.main.async {
                HUD.dismissLoading()
                HUD.error(title: "update_nickname_failed".localized)
            }
        }

        Task {
            do {
                let request = UserInfoUpdateRequest(nickname: name, avatar: avatar)
                let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.Profile.updateInfo(request))
                if response.httpCode != 200 {
                    failed()
                } else {
                    success()
                }
            } catch {
                failed()
            }
        }
    }
}
