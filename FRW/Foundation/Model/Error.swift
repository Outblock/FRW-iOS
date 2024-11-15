//
//  Error.swift
//  Flow Wallet
//
//  Created by Selina on 8/6/2022.
//

import Foundation

enum LLError: Error {
    case aesKeyEncryptionFailed
    case aesEncryptionFailed
    case missingUserInfoWhilBackup
    case emptyiCloudBackup
    case alreadyHaveWallet
    case emptyWallet
    case decryptBackupFailed
    case incorrectPhrase
    case emptyEncryptKey
    case restoreLoginFailed
    case accountNotFound
    case fetchUserInfoFailed
    case invalidAddress
    case invalidCadence
    case signFailed
    case decodeFailed
    case unknown
}

enum WalletError: Error {
    case fetchFailed
    case fetchBalanceFailed
    case existingMnemonicMismatch
    case storeAndActiveMnemonicFailed
    case mnemonicMissing
    case emptyPublicKey
    case insufficientBalance
    case securityVerifyFailed
}

enum BackupError: Error {
    case missingUserName
    case missingMnemonic
    case missingUid
    case hexStringToDataFailed
    case decryptMnemonicFailed
    case topVCNotFound
    case fileIsNotExistOnCloud
    case CloudFileData
}

enum GoogleBackupError: Error {
    case missingLoginUser
    case noDriveScope
    case createFileError
}

enum iCloudBackupError: Error {
    case initError
    case invalidLoadData
    case checkFileUploadedStatusError
    case openFileError
    case opendFileDataIsNil
    case noDataToSave
    case saveToDataFailed
    case fileIsNotExist
}

enum NFTError: Error {
    case noCollectionInfo
    case invalidTokenId
    case sendInvalidAddress
}

enum StakingError: Error {
    case stakingDisabled
    case stakingNeedSetup
    case stakingSetupFailed
    case stakingCreateDelegatorIdFailed
    case unknown

    var desc: String {
        switch self {
        case .stakingDisabled:
            return "staking_not_enabled".localized
        case .stakingSetupFailed:
            return "staking_setup_failed".localized
        default:
            return "request_failed".localized
        }
    }
}

enum EVMError: Error {
    case createAccount
    case findAddress
    case transactionResult
}
