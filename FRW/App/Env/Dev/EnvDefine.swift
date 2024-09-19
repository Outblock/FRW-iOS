//
//  EnvDefine.swift
//  Flow Wallet
//
//  Created by Selina on 22/12/2022.
//

import Foundation

let AppGroupName = "group.com.flowfoundation.wallet.dev"
let AppBundleName = "com.flowfoundation.wallet.dev"
let isDevModel = true
let FirstFavNFTImageURL = "FirstFavNFTImageURL"

func groupUserDefaults() -> UserDefaults? {
    return UserDefaults(suiteName: AppGroupName)
}
