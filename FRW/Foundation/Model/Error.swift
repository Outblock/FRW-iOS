//
//  Error.swift
//  Flow Wallet
//
//  Created by Selina on 8/6/2022.
//

import Foundation

// MARK: - LLError

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

// MARK: - WalletError

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

// MARK: - BackupError

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

// MARK: - GoogleBackupError

enum GoogleBackupError: Error {
    case missingLoginUser
    case noDriveScope
    case createFileError
}

// MARK: - iCloudBackupError

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

// MARK: - NFTError

enum NFTError: Error {
    case noCollectionInfo
    case invalidTokenId
    case sendInvalidAddress
}

// MARK: - StakingError

enum StakingError: Error {
    case stakingDisabled
    case stakingNeedSetup
    case stakingSetupFailed
    case stakingCreateDelegatorIdFailed
    case unknown

    // MARK: Internal

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

// MARK: - EVMError

enum EVMError: Error {
    case createAccount
    case findAddress
    case transactionResult
}

// MARK: - CadenceError

enum CadenceError: Error {
    case empty

    // MARK: Internal

    var message: String {
        switch self {
        case .empty:
            "empty script"
        }
    }
}
