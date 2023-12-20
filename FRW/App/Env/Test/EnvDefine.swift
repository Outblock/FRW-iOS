//
//  EnvDefine.swift
//  Flow Reference Wallet
//
//  Created by Selina on 22/12/2022.
//

import Foundation

let AppGroupName = "group.io.outblock.lilico.dev"

let FirstFavNFTImageURL = "FirstFavNFTImageURL"

func groupUserDefaults() -> UserDefaults? {
    return UserDefaults(suiteName: AppGroupName)
}
