//
//  NotificationDefine.swift
//  Flow Wallet
//
//  Created by Selina on 21/6/2022.
//

import Foundation

extension Notification.Name {
    public static let walletHiddenFlagUpdated = Notification.Name("walletHiddenFlagUpdated")
    public static let quoteMarketUpdated = Notification.Name("quoteMarketUpdated")
    public static let coinSummarysUpdated = Notification.Name("coinSummarysUpdated")
    public static let addressBookDidAdd = Notification.Name("addressBookDidAdd")
    public static let addressBookDidEdit = Notification.Name("addressBookDidEdit")
    public static let backupTypeDidChanged = Notification.Name("backupTypeDidChanged")
    public static let nftFavDidChanged = Notification.Name("nftFavDidChanged")
    public static let nftCollectionsDidChanged = Notification.Name("nftCollectionsDidChanged")
    public static let nftCacheDidChanged = Notification.Name("nftCacheDidChanged")

    public static let transactionManagerDidChanged = Notification
        .Name("transactionManagerDidChanged")
    public static let transactionStatusDidChanged = Notification.Name("transactionStatusDidChanged")

    public static let transactionCountDidChanged = Notification.Name("transactionCountDidChanged")

    public static let watchAddressDidChanged = Notification.Name("watchAddressDidChanged")

    public static let webBookmarkDidChanged = Notification.Name("webBookmarkDidChanged")
    public static let willResetWallet = Notification.Name("willResetWallet")
    public static let didResetWallet = Notification.Name("didResetWallet")
    public static let didFinishAccountLogin = Notification.Name("didFinishedAccountLogin")

    public static let networkChange = Notification.Name("networkChange")

    public static let openNFTCollectionList = Notification.Name("openNFTCollectionList")
    public static let toggleSideMenu = Notification.Name("toggleSideMenu")

    public static let nftCountChanged = Notification.Name("nftCountChanged")
    public static let childAccountChanged = Notification.Name("childAccountChanged")

    public static let syncDeviceStatusDidChanged = Notification.Name("syncDeviceStatusDidChanged")

    public static let nftDidChangedByMoving = Notification.Name("nftDidChangedByMoving")

    public static let remoteConfigDidUpdate = Notification.Name("remoteConfigDidUpdate")
    public static let accountDataDidUpdate = Notification.Name("accountDataDidUpdate")
}
