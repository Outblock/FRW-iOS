//
//  WalletManager.swift
//  Lilico
//
//  Created by Hao Fu on 30/12/21.
//

import Combine
import Flow
import Foundation
import KeychainAccess
import WalletCore
import Kingfisher

// MARK: - Define

extension WalletManager {
    static let flowPath = "m/44'/539'/0'/0/0"
    static let mnemonicStrength: Int32 = 128
    private static let defaultBundleID = "io.outblock.lilico"
    private static let mnemonicStoreKeyPrefix = "lilico.mnemonic"
    private static let walletFetchInterval: TimeInterval = 20
    
    private enum CacheKeys: String {
        case walletInfo
        case supportedCoins
        case activatedCoins
        case coinBalances
    }
}

class WalletManager: ObservableObject {
    static let shared = WalletManager()

    @Published var walletInfo: UserWalletResponse?
    @Published var supportedCoins: [TokenModel]?
    @Published var activatedCoins: [TokenModel] = []
    @Published var coinBalances: [String: Double] = [:]
    @Published var childAccount: ChildAccount? = nil
    var accessibleManager: ChildAccountManager.AccessibleManager = ChildAccountManager.AccessibleManager()
    
    private var childAccountInited: Bool = false

    private var hdWallet: HDWallet?

    var mainKeychain = Keychain(service: Bundle.main.bundleIdentifier ?? defaultBundleID)
        .label("Lilico app backup")
        .synchronizable(true)
        .accessibility(.whenUnlocked)

    private var walletInfoRetryTimer: Timer?
    private var cancellableSet = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(reset), name: .willResetWallet, object: nil)
        
        if UserManager.shared.activatedUID != nil {
            restoreMnemonicForCurrentUser()
            loadCacheData()
        }
        
        UserManager.shared.$activatedUID
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { activatedUID in
                self.reloadWalletInfo()
            }.store(in: &cancellableSet)
    }
    
    func bindChildAccountManager() {
        ChildAccountManager.shared.$selectedChildAccount
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink(receiveValue: { newChildAccount in
                log.info("change account did changed")
                self.childAccount = newChildAccount
                
                if self.childAccountInited {
                    Task {
                        try? await self.fetchWalletDatas()
                    }
                }
                
                self.childAccountInited = true
                NotificationCenter.default.post(name: .childAccountChanged)
            }).store(in: &cancellableSet)
    }
    
    private func loadCacheData() {
        guard let uid = UserManager.shared.activatedUID else { return }
        let cacheWalletInfo = MultiAccountStorage.shared.getWalletInfo(uid)
        
        Task {
            let cacheSupportedCoins = try? await PageCache.cache.get(forKey: CacheKeys.supportedCoins.rawValue, type: [TokenModel].self)
            let cacheActivatedCoins = try? await PageCache.cache.get(forKey: CacheKeys.activatedCoins.rawValue, type: [TokenModel].self)
            let cacheBalances = try? await PageCache.cache.get(forKey: CacheKeys.coinBalances.rawValue, type: [String: Double].self)
            
            DispatchQueue.main.async {
                self.walletInfo = cacheWalletInfo
                
                if let cacheSupportedCoins = cacheSupportedCoins, let cacheActivatedCoins = cacheActivatedCoins {
                    self.supportedCoins = cacheSupportedCoins
                    self.activatedCoins = cacheActivatedCoins
                }
                
                if let cacheBalances = cacheBalances {
                    self.coinBalances = cacheBalances
                }
            }
        }
    }
}

// MARK: - Child Account
extension WalletManager {
    var isSelectedChildAccount: Bool {
        return childAccount != nil
    }
    
    var selectedAccountIcon: String {
        if let childAccount = childAccount {
            return childAccount.icon
        }
        
        return UserManager.shared.userInfo?.avatar.convertedAvatarString() ?? ""
    }
    
    var selectedAccountNickName: String {
        if let childAccount = childAccount {
            return childAccount.aName
        }
        
        return UserManager.shared.userInfo?.nickname ?? "Lilico"
    }
    
    var selectedAccountWalletName: String {
        if let childAccount = childAccount {
            return "\(childAccount.aName) Wallet"
        }
        
        if let walletInfo = self.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getName ?? "wallet".localized
        }
        
        return "wallet".localized
    }
    
    var selectedAccountAddress: String {
        if let childAccount = childAccount {
            return childAccount.addr ?? ""
        }
        
        if let walletInfo = self.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getAddress ?? "0x"
        }
        
        return "0x"
    }
    
    func changeNetwork(_ type: LocalUserDefaults.FlowNetworkType) {
        if LocalUserDefaults.shared.flowNetwork == type {
            if isSelectedChildAccount {
                ChildAccountManager.shared.select(nil)
            }
            return
        }
        
        LocalUserDefaults.shared.flowNetwork = type
        FlowNetwork.setup()
        
        if getPrimaryWalletAddress() == nil {
            WalletManager.shared.reloadWalletInfo()
        } else {
            self.walletInfo = self.walletInfo
        }
        
        NotificationCenter.default.post(name: .networkChange)
    }
}

// MARK: - Reset

extension WalletManager {
    private func resetProperties() {
        self.hdWallet = nil
        self.walletInfo = nil
        self.supportedCoins = nil
        self.activatedCoins = []
        self.coinBalances = [:]
    }
    
    @objc private func reset() {
        debugPrint("WalletManager: reset start")
        
        resetProperties()
        
        debugPrint("WalletManager: wallet info clear success")
        
        do {
            try removeCurrentMnemonicDataFromKeyChain()
            debugPrint("WalletManager: mnemonic remove success")
        } catch {
            debugPrint("WalletManager: remove mnemonic failed")
        }
        
        debugPrint("WalletManager: reset finished")
    }
    
    private func removeCurrentMnemonicDataFromKeyChain() throws {
        guard let uid = UserManager.shared.activatedUID else {
            return
        }
        
        try mainKeychain.remove(getMnemonicStoreKey(uid: uid))
    }
}

// MARK: - Getter

extension WalletManager {
    func getCurrentMnemonic() -> String? {
        return hdWallet?.mnemonic
    }
    
    func getCurrentPublicKey() -> String? {
        return hdWallet?.getPublicKey()
    }
    
    func getCurrentPrivateKey() -> String? {
        return hdWallet?.getPrivateKey()
    }

    func getCurrentFlowAccountKey() -> Flow.AccountKey? {
        return hdWallet?.flowAccountKey
    }
    
    func getPrimaryWalletAddress() -> String? {
        return walletInfo?.currentNetworkWalletModel?.getAddress
    }
    
    func getFlowNetworkTypeAddress(network: LocalUserDefaults.FlowNetworkType) -> String? {
        return walletInfo?.getNetworkWalletModel(network: network)?.getAddress
    }
    
    /// get custom watch address first, then primary address, this method is only used for tab2.
    func getPrimaryWalletAddressOrCustomWatchAddress() -> String? {
        return LocalUserDefaults.shared.customWatchAddress ?? getPrimaryWalletAddress()
    }
    
    /// watch address -> child account address -> primary address
    func getWatchAddressOrChildAccountAddressOrPrimaryAddress() -> String? {
        if let customAddress = LocalUserDefaults.shared.customWatchAddress, !customAddress.isEmpty {
            return customAddress
        }
        
        if let childAccount = childAccount {
            return childAccount.addr
        }
        
        if let walletInfo = self.walletInfo?.currentNetworkWalletModel {
            return walletInfo.getAddress
        }
        
        return nil
    }
    
    var isSandboxnetEnabled: Bool {
        return walletInfo?.wallets?.first(where: { $0.chainId == LocalUserDefaults.FlowNetworkType.sandboxnet.rawValue })?.getAddress != nil
    }
    
    func isTokenActivated(symbol: String) -> Bool {
        for token in activatedCoins {
            if token.symbol == symbol {
                return true
            }
        }
        
        return false
    }
    
    func getToken(bySymbol symbol: String) -> TokenModel? {
        for token in activatedCoins {
            if token.symbol?.lowercased() == symbol.lowercased() {
                return token
            }
        }
        
        return nil
    }
    
    func getBalance(bySymbol symbol: String) -> Double {
        return coinBalances[symbol] ?? coinBalances[symbol.lowercased()] ?? coinBalances[symbol.uppercased()] ?? 0
    }
}

// MARK: - Server Wallet

extension WalletManager {
    /// Request server create wallet address, DO NOT call it multiple times.
    func asyncCreateWalletAddressFromServer() {
        Task {
            do {
                let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.User.userAddress)
                debugPrint("WalletManager -> asyncCreateWalletAddressFromServer success")
            } catch {
                debugPrint("WalletManager -> asyncCreateWalletAddressFromServer failed")
            }
        }
    }

    private func startWalletInfoRetryTimer() {
        debugPrint("WalletManager -> startWalletInfoRetryTimer")
        stopWalletInfoRetryTimer()
        let timer = Timer.scheduledTimer(timeInterval: WalletManager.walletFetchInterval, target: self, selector: #selector(onWalletInfoRetryTimer), userInfo: nil, repeats: false)
        walletInfoRetryTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopWalletInfoRetryTimer() {
        if let timer = walletInfoRetryTimer {
            timer.invalidate()
            walletInfoRetryTimer = nil
        }
    }

    @objc private func onWalletInfoRetryTimer() {
        debugPrint("WalletManager -> onWalletInfoRetryTimer")
        reloadWalletInfo()
    }

    func reloadWalletInfo() {
        log.debug("reloadWalletInfo")
        stopWalletInfoRetryTimer()
        
        guard let uid = UserManager.shared.activatedUID else { return }

        Task {
            do {
                let response: UserWalletResponse = try await Network.request(LilicoAPI.User.userWallet)
                
                if UserManager.shared.activatedUID != uid { return }
                
                DispatchQueue.main.async {
                    self.walletInfo = response
                    try? MultiAccountStorage.shared.saveWalletInfo(response, uid: uid)
                    self.pollingWalletInfoIfNeeded()
                }
            } catch {
                if UserManager.shared.activatedUID != uid { return }
                log.error("reloadWalletInfo failed", context: error)
                
                DispatchQueue.main.async {
                    self.startWalletInfoRetryTimer()
                }
            }
        }
    }

    /// polling wallet info, if wallet address is not exists
    private func pollingWalletInfoIfNeeded() {
        debugPrint("WalletManager -> pollingWalletInfoIfNeeded")
        let isEmptyBlockChain = walletInfo?.currentNetworkWalletModel?.isEmptyBlockChain ?? true
        if isEmptyBlockChain {
            startWalletInfoRetryTimer()
            
            Task {
                do {
                    let _: Network.EmptyResponse = try await Network.requestWithRawModel(LilicoAPI.User.manualCheck)
                } catch {
                    debugPrint(error)
                }
            }
            
        } else {
            // is valid data, save to page cache
            if let info = walletInfo {
                PageCache.cache.set(value: info, forKey: CacheKeys.walletInfo.rawValue)
            }
        }
    }
}

// MARK: - Mnemonic Create & Save

extension WalletManager {
    func createHDWallet(mnemonic: String? = nil, passphrase: String = "") -> HDWallet? {
        if let mnemonic = mnemonic {
            return HDWallet(mnemonic: mnemonic, passphrase: passphrase)
        }

        return HDWallet(strength: WalletManager.mnemonicStrength, passphrase: passphrase)
    }

    func storeAndActiveMnemonicToKeychain(_ mnemonic: String, uid: String) throws {
        guard var data = mnemonic.data(using: .utf8) else {
            throw WalletError.storeAndActiveMnemonicFailed
        }

        defer {
            data = Data()
        }

        var encodedData = try WalletManager.encryptionChaChaPoly(key: uid, data: data)
        defer {
            encodedData = Data()
        }
        
        if let existingMnemonic = getMnemonicFromKeychain(uid: uid) {
            if existingMnemonic != mnemonic {
                log.error("existingMnemonic should equal the current")
                throw WalletError.existingMnemonicMismatch
            }
        } else {
            try set(toMainKeychain: encodedData, forKey: getMnemonicStoreKey(uid: uid), comment: "Lilico user uid: \(uid)")
        }
        
        DispatchQueue.main.async {
            self.resetProperties()
            let _ = self.activeMnemonic(mnemonic)
        }
    }
}

// MARK: - Mnemonic Restore

extension WalletManager {
    func getMnemonicFromKeychain(uid: String) -> String? {
        if var encryptedData = getEncryptedMnemonicData(uid: uid),
           var decryptedData = try? WalletManager.decryptionChaChaPoly(key: uid, data: encryptedData),
           var mnemonic = String(data: decryptedData, encoding: .utf8)
        {
            defer {
                encryptedData = Data()
                decryptedData = Data()
                mnemonic = ""
            }

            return mnemonic
        }
        
        return nil
    }
    
    private func restoreMnemonicForCurrentUser() {
        if let uid = UserManager.shared.activatedUID {
            if !restoreMnemonicFromKeychain(uid: uid) {
                HUD.error(title: "no_private_key".localized)
            }
        }
    }

    private func restoreMnemonicFromKeychain(uid: String) -> Bool {
        do {
            if var encryptedData = getEncryptedMnemonicData(uid: uid)
            {
                debugPrint("WalletManager -> start restore mnemonic from keychain, uid = \(uid), encryptedData.count = \(encryptedData.count)")
                
                var decryptedData = try WalletManager.decryptionChaChaPoly(key: uid, data: encryptedData)
                defer {
                    encryptedData = Data()
                    decryptedData = Data()
                }
                
                if var mnemonic = String(data: decryptedData, encoding: .utf8) {
                    defer {
                        mnemonic = ""
                    }
                    
                    return activeMnemonic(mnemonic)
                }
            }
        } catch {
            debugPrint("WalletManager -> restoreMnemonicFromKeyChain failed: uid = \(uid), error = \(error)")
        }

        return false
    }

    private func activeMnemonic(_ mnemonic: String) -> Bool {
        guard let model = createHDWallet(mnemonic: mnemonic) else {
            return false
        }

        hdWallet = model
        return true
    }
}

// MARK: - Internal Getter

extension WalletManager {
    private func getMnemonicStoreKey(uid: String) -> String {
        return "\(WalletManager.mnemonicStoreKeyPrefix).\(uid)"
    }

    private func getEncryptedMnemonicData(uid: String) -> Data? {
        return getData(fromMainKeychain: getMnemonicStoreKey(uid: uid))
    }
}

// MARK: - Coins

extension WalletManager {
    func fetchWalletDatas() async throws {
        guard getPrimaryWalletAddress() != nil else {
            return
        }
        
        log.debug("fetchWalletDatas")
        
        try fetchSupportedCoins()
        try await fetchActivatedCoins()
        try await fetchBalance()
        try await fetchAccessible()
        ChildAccountManager.shared.refresh()
    }

    private func fetchSupportedCoins() throws {
        let coins: [TokenModel] = try FirebaseConfig.flowCoins.fetch()
        let validCoins = coins.filter { $0.getAddress()?.isEmpty == false }
        DispatchQueue.main.sync {
            self.supportedCoins = validCoins
        }
        
        PageCache.cache.set(value: validCoins, forKey: CacheKeys.supportedCoins.rawValue)
    }

    private func fetchActivatedCoins() async throws {
        guard let supportedCoins = supportedCoins, supportedCoins.count != 0 else {
            DispatchQueue.main.sync {
                self.activatedCoins.removeAll()
            }
            return
        }

        let address = selectedAccountAddress
        if address.isEmpty {
            DispatchQueue.main.sync {
                self.activatedCoins.removeAll()
            }
            return
        }

        let enabledList = try await FlowNetwork.checkTokensEnable(address: Flow.Address(hex: address), tokens: supportedCoins)
        if enabledList.count != supportedCoins.count {
            throw WalletError.fetchFailed
        }

        var list = [TokenModel]()
        for (index, value) in enabledList.enumerated() {
            if value == true {
                list.append(supportedCoins[index])
            }
        }

        DispatchQueue.main.sync {
            self.activatedCoins = list
        }
        preloadActivatedIcons()
        
        PageCache.cache.set(value: list, forKey: CacheKeys.activatedCoins.rawValue)
    }

    func fetchBalance() async throws {
        guard activatedCoins.count > 0 else {
            return
        }

        let address = selectedAccountAddress
        if address.isEmpty {
            throw WalletError.fetchBalanceFailed
        }

        let balanceList = try await FlowNetwork.fetchBalance(at: Flow.Address(hex: address), with: activatedCoins)
        if activatedCoins.count != balanceList.count {
            throw WalletError.fetchBalanceFailed
        }

        var newBalanceMap: [String: Double] = [:]

        for (index, value) in activatedCoins.enumerated() {
            let balance = balanceList[index]

            guard let symbol = value.symbol else {
                continue
            }

            newBalanceMap[symbol] = balance
        }

        DispatchQueue.main.sync {
            self.coinBalances = newBalanceMap
        }
        
        PageCache.cache.set(value: newBalanceMap, forKey: CacheKeys.coinBalances.rawValue)
    }
    
    func fetchAccessible() async throws {
        try await accessibleManager.fetchFT()
    }
}

// MARK: - Helper

extension WalletManager {
    private func preloadActivatedIcons() {
        for token in activatedCoins {
            if let url = token.icon {
                KingfisherManager.shared.retrieveImage(with: url) { _ in
                    
                }
            }
        }
    }

    // MARK: -

    private func set(toMainKeychain value: String, forKey key: String) throws {
        try mainKeychain.set(value, key: key)
    }

    private func set(toMainKeychain value: Data, forKey key: String, comment: String? = nil) throws {
        if let comment = comment {
            try mainKeychain.comment(comment).set(value, key: key)
        } else {
            try mainKeychain.set(value, key: key)
        }
    }

    private func getString(fromMainKeychain key: String) -> String? {
        return try? mainKeychain.getString(key)
    }

    private func getData(fromMainKeychain key: String) -> Data? {
        return try? mainKeychain.getData(key)
    }

    static func encryptionAES(key: String, iv: String = LocalEnvManager.shared.aesIV, data: Data) throws -> Data {
        guard var keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            throw LLError.aesKeyEncryptionFailed
        }
        if keyData.count > 16 {
            keyData = keyData.prefix(16)
        } else {
            keyData = keyData.paddingZeroRight(blockSize: 16)
        }

        guard let encrypted = AES.encryptCBC(key: keyData, data: data, iv: ivData, mode: .pkcs7) else {
            throw LLError.aesEncryptionFailed
        }
        return encrypted
    }

    static func decryptionAES(key: String, iv: String = LocalEnvManager.shared.aesIV, data: Data) throws -> Data {
        guard var keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            throw LLError.aesKeyEncryptionFailed
        }

        if keyData.count > 16 {
            keyData = keyData.prefix(16)
        } else {
            keyData = keyData.paddingZeroRight(blockSize: 16)
        }

        guard let decrypted = AES.decryptCBC(key: keyData, data: data, iv: ivData, mode: .pkcs7) else {
            throw LLError.aesEncryptionFailed
        }
        return decrypted
    }
    
    static func encryptionChaChaPoly(key: String, data: Data) throws -> Data {
        guard let cipher = ChaChaPolyCipher(key: key) else {
            throw EncryptionError.initFailed
        }
        return try cipher.encrypt(data: data)
    }
    
    static func decryptionChaChaPoly(key: String, data: Data) throws -> Data {
        guard let cipher = ChaChaPolyCipher(key: key) else {
            throw EncryptionError.initFailed
        }
        return try cipher.decrypt(combinedData: data)
    }
}

extension WalletManager: FlowSigner {
    public var address: Flow.Address {
        guard let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return Flow.Address(hex: "")
        }
        return Flow.Address(hex: address)
    }
    
    public var hashAlgo: Flow.HashAlgorithm {
        // TODO: FIX ME, make it dynamic
        .SHA2_256
    }
    
    public var signatureAlgo: Flow.SignatureAlgorithm {
        // TODO: FIX ME, make it dynamic
        .ECDSA_SECP256k1
    }
    
    public var keyIndex: Int {
        // TODO: FIX ME, make it dynamic
        0
    }
    
    public func sign(transaction: Flow.Transaction, signableData: Data) async throws -> Data {
        guard let hdWallet = hdWallet else {
            throw LLError.emptyWallet
        }
        
        var privateKey = hdWallet.getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        let hashedData = Hash.sha256(data: signableData)
        
        defer {
            privateKey = PrivateKey()
        }
        
        guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
            throw LLError.signFailed
        }
        
        signature.removeLast()
        
        return signature
    }
    
    public func sign(signableData: Data) async throws -> Data {
        guard let hdWallet = hdWallet else {
            throw LLError.emptyWallet
        }
        
        var privateKey = hdWallet.getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        let hashedData = Hash.sha256(data: signableData)
        
        defer {
            privateKey = PrivateKey()
        }
        
        guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
            throw LLError.signFailed
        }
        
        signature.removeLast()
        
        return signature
    }
    
    public func signSync(signableData: Data) -> Data? {
        guard let hdWallet = hdWallet else {
            return nil
        }
        
        var privateKey = hdWallet.getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        let hashedData = Hash.sha256(data: signableData)
        
        defer {
            privateKey = PrivateKey()
        }
        
        guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
            return nil
        }
        signature.removeLast()
        return signature
    }
}

extension HDWallet {
    
    func getPublicKey() -> String {
        let p256PublicKey = getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
            .getPublicKeySecp256k1(compressed: false)
            .uncompressed
            .data
            .hexValue
            .dropPrefix("04")
        return p256PublicKey
    }
    
    func getPrivateKey() -> String {
        let privateKey = getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        return privateKey.data.hexValue
    }


    func sign(_ text: String) -> String? {
        guard let textData = text.data(using: .utf8) else {
            return nil
        }

        let data = Flow.DomainTag.user.normalize + textData
        return sign(data)
    }

    func sign(_ data: Data) -> String? {
        var privateKey = getKeyByCurve(curve: .secp256k1, derivationPath: WalletManager.flowPath)
        
        defer {
            privateKey = PrivateKey()
        }
        
        let hashedData = Hash.sha256(data: data)
        guard var signature = privateKey.sign(digest: hashedData, curve: .secp256k1) else {
            return nil
        }

        signature.removeLast()
        return signature.hexValue
    }

    var flowAccountKey: Flow.AccountKey {
        let p256PublicKey = getPublicKey()
        let key = Flow.PublicKey(hex: String(p256PublicKey))
        return Flow.AccountKey(publicKey: key,
                               signAlgo: .ECDSA_SECP256k1,
                               hashAlgo: .SHA2_256,
                               weight: 1000)
    }

    var flowAccountP256Key: Flow.AccountKey {
        let p256PublicKey = getKeyByCurve(curve: .nist256p1, derivationPath: WalletManager.flowPath)
            .getPublicKeyNist256p1()
            .uncompressed
            .data
            .hexValue
            .dropPrefix("04")
        let key = Flow.PublicKey(hex: String(p256PublicKey))
        return Flow.AccountKey(publicKey: key,
                               signAlgo: .ECDSA_P256,
                               hashAlgo: .SHA2_256,
                               weight: 1000)
    }
}

extension Flow.AccountKey {
    func toCodableModel() -> AccountKey {
        return AccountKey(hashAlgo: hashAlgo.index,
                          publicKey: publicKey.hex,
                          sign_algo: signAlgo.index,
                          weight: weight)
    }
}

extension String {
    func dropPrefix(_ prefix: String) -> Self {
        if hasPrefix(prefix) {
            return String(dropFirst(prefix.count))
        }
        return self
    }
}
