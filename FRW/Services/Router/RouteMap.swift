//
//  RouterMap.swift
//  Flow Wallet
//
//  Created by Selina on 25/7/2022.
//

import Flow
import SafariServices
import SwiftUI
import SwiftUIX
import UIKit

enum RouteMap {}

// MARK: - Restore Login

extension RouteMap {
    enum RestoreLogin {
        case root
        case restoreManual
        case chooseAccount([BackupManager.DriveItem], BackupManager.BackupType)
        case enterRestorePwd(BackupManager.DriveItem, BackupManager.BackupType)
        case syncQC
        case syncAccount(SyncInfo.User)
        case syncDevice(SyncAddDeviceViewModel)

        case restoreList
        case restoreMulti
        case multiConnect([MultiBackupType])
        case multiAccount([[MultiBackupManager.StoreItem]])
        case inputMnemonic((String) -> ())
    }
}

extension RouteMap.RestoreLogin: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: RestoreWalletView())
        case .restoreManual:
            navi.push(content: InputMnemonicView())
        case .chooseAccount(let items, let backupType):
            navi.push(content: ChooseAccountView(driveItems: items, backupType: backupType))
        case .enterRestorePwd(let item, let backupType):
            navi.push(content: EnterRestorePasswordView(driveItem: item, backupType: backupType))
        case .syncQC:
            navi.push(content: SyncAccountView())
        case .syncAccount(let info):
            navi.push(content: SyncConfirmView(user: info))
        case .syncDevice(let vm):
            let vc = CustomHostingController(rootView: SyncAddDeviceView(viewModel: vm))
            Router.topPresentedController().present(vc, animated: true, completion: nil)

        case .restoreList:
            navi.push(content: RestoreListView())
        case .restoreMulti:
            navi.push(content: RestoreMultiBackupOptionView())
        case .multiConnect(let item):
            navi.push(content: RestoreMultiConnectView(items: item))
        case .multiAccount(let list):
            navi.push(content: RestoreMultiAccountView(list))
        case .inputMnemonic(let callback):
            navi.push(content: RestoreMultiInputMnemonicView(callback: callback))
        }
    }
}

// MARK: - Register

extension RouteMap {
    enum Register {
        case root(String?)
        case username(String?)
    }
}

extension RouteMap.Register: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root(let mnemonic):
            navi.push(content: TermsAndPolicy(mnemonic: mnemonic))
        case .username(let mnemonic):
            navi.push(content: UsernameView(mnemonic: mnemonic))
        }
    }
}

// MARK: - Backup

extension RouteMap {
    enum Backup {
        case backupRoot
        case chooseBackupMethod
        case backupToCloud(BackupManager.BackupType)
        case backupManual

        case backupList
        case multiBackup([MultiBackupType])
        case uploadMulti([MultiBackupType])
        case showPhrase(String)
        case backupDetail(KeyDeviceModel)

        case createPin
        case confirmPin(String)
        case verityPin(MultiBackupVerifyPinViewModel.From, MultiBackupVerifyPinViewModel.VerifyCallback)
    }
}

extension RouteMap.Backup: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .backupRoot:
            navi.push(content: TYNKView())
        case .chooseBackupMethod:
            guard let rootVC = navi.viewControllers.first else {
                return
            }

            var newVCList = [rootVC]
            let vc = RouteableUIHostingController(rootView: RecoveryPhraseView(backupMode: false))
            newVCList.append(vc)
            navi.setViewControllers(newVCList, animated: true)
        case .backupToCloud(let type):
            navi.push(content: BackupPasswordView(backupType: type))
        case .backupManual:
            navi.push(content: ManualBackupView())

        case .backupList:
            navi.push(content: BackupListView())
        case .multiBackup(let items):
            navi.push(content: BackupMultiView(items: items))
        case .uploadMulti(let items):
            navi.push(content: BackupUploadView(items: items))
        case .showPhrase(let mnemonic):
            navi.push(content: MultiBackupPhraseView(mnemonic: mnemonic))
        case .backupDetail(let item):
            navi.push(content: MultiBackupDetailView(item: item))
        case .createPin:
            navi.push(content: MultiBackupCreatePinView())
        case .confirmPin(let pin):
            navi.push(content: MultiBackupConfirmPinView(lastPin: pin))
        case .verityPin(let from, let callback):
            navi.push(content: MultiBackupVerifyPinView(from: from, callback: callback))
        }
    }
}

// MARK: - Wallet

extension RouteMap {
    enum Wallet {
        case addToken
        case tokenDetail(TokenModel, Bool)
        case receive
        case send(_ address: String = "")
        case sendAmount(Contact, TokenModel, isPush: Bool = true)
        case scan(SPQRCodeCallback, click: SPQRCodeCallback? = nil)
        case buyCrypto
        case transactionList(String?)
        case swap(TokenModel?)
        case selectToken(TokenModel?, [TokenModel], (TokenModel) -> ())
        case stakingList
        case stakingSelectProvider
        case stakeGuide
        case stakeAmount(StakingProvider, isUnstake: Bool = false)
        case stakeDetail(StakingProvider, StakingNode)
        case stakeSetupConfirm(StakeAmountViewModel)
        case backToTokenDetail
        case jailbreakAlert
        case pushAlert
        case receiveQR
        case enableEVM
        case moveNFTs
        case moveAssets
        case moveToken(TokenModel)
        case selectMoveToken(TokenModel?,(TokenModel)->())
    }
}

extension RouteMap.Wallet: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .addToken:
            navi.push(content: AddTokenView(vm: AddTokenViewModel()))
        case .tokenDetail(let token, let isAccessible):
            navi.push(content: TokenDetailView(token: token, accessible: isAccessible))
        case .receive:
            let vc = UIHostingController(rootView: WalletReceiveView())
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical
            vc.view.backgroundColor = .clear
            navi.present(vc, animated: false)
        case .send(let address):
            navi.present(content: WalletSendView(address: address))
        case .sendAmount(let contact, let token, let isPush):
            if isPush {
                navi.push(content: WalletSendAmountView(target: contact, token: token))
            } else {
                navi.present(content: WalletSendAmountView(target: contact, token: token))
            }
        case .scan(let handler, let click):
//            let rootVC = Router.topPresentedController()
            SPQRCode.scanning(handled: handler, click: click, on: navi)
        case .buyCrypto:
            let vc = CustomHostingController(rootView: BuyProvderView())
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .transactionList(let contractId):
            let vc = TransactionListViewController(contractId: contractId)
            navi.pushViewController(vc, animated: true)
        case .swap(let fromToken):
            navi.present(content: fromToken != nil ? SwapView(defaultFromToken: fromToken) : SwapView())
        case .selectToken(let selectedToken, let disableTokens, let callback):
            let vm = AddTokenViewModel(selectedToken: selectedToken, disableTokens: disableTokens, selectCallback: callback)
            navi.present(content: AddTokenView(vm: vm))
        case .stakingList:
            navi.push(content: StakingListView())
        case .stakingSelectProvider:
            navi.push(content: SelectProviderView())
        case .stakeGuide:
            navi.push(content: StakeGuideView())
        case .stakeAmount(let provider, let isUnstake):
            navi.push(content: StakeAmountView(provider: provider, isUnstake: isUnstake))
        case .stakeDetail(let provider, let node):
            navi.push(content: StakingDetailView(provider: provider, node: node))
        case .stakeSetupConfirm(let vm):
            let vc = CustomHostingController(rootView: StakeAmountView.StakeSetupView(vm: vm))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .backToTokenDetail:
            if let existVC = navi.viewControllers.first(where: { $0 as? RouteableUIHostingController<TokenDetailView> != nil }) {
                navi.popToViewController(existVC, animated: true)
                return
            }

            navi.popToRootViewController(animated: true)
        case .jailbreakAlert:
            let vc = CustomHostingController(rootView: JailbreakAlertView())
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .pushAlert:
            let vc = RouteableUIHostingController(rootView: PushAlertView())
            vc.modalPresentationStyle = .fullScreen
            let contentNavi = RouterNavigationController(rootViewController: vc)
            contentNavi.modalPresentationCapturesStatusBarAppearance = true
            contentNavi.modalPresentationStyle = .fullScreen
            Router.topPresentedController().present(contentNavi, animated: true)
        case .receiveQR:
            navi.present(content: ReceiveQRView())
        case .enableEVM:
            navi.push(content: EVMEnableView())
        case .moveNFTs:
            let vc = CustomHostingController(rootView: MoveNFTsView(),onlyLarge: true)
            navi.present(vc, animated: true, completion: nil)
        case .moveAssets:
            let vc = CustomHostingController(rootView: MoveAssetsView(showToken: {}, closeAction: {}))
            navi.present(vc, animated: true, completion: nil)
        case .moveToken(let tokenModel):
            let vc = CustomHostingController(rootView: MoveTokenView(tokenModel: tokenModel, isPresent: .constant(true)))
            navi.present(vc, animated: true, completion: nil)
        case .selectMoveToken(let token, let callback):
            let vm = AddTokenViewModel(selectedToken: token, disableTokens: [], selectCallback: callback)
            Router.topPresentedController().present(content: AddTokenView(vm: vm))
        }
    }
}

// MARK: - Profile

extension RouteMap {
    enum Profile {
        case themeChange
        case developer
        case about
        case addressBook
        case edit
        case editName
        case editAvatar
        case backupChange
        case walletSetting(Bool,String)
        case privateKey(Bool)
        case walletConnect
        case manualBackup(Bool)
        case security(Bool)
        case inbox
        case resetWalletConfirm
        case currency
        case accountSetting
        case accountDetail(ChildAccount)
        case switchProfile
        case editChildAccount(ChildAccount)
        case backToAccountSetting

        case linkedAccount
        case accountKeys
        case devices
        case deviceInfo(DeviceInfoModel)
        
        case keychain
        case walletList
    }
}

extension RouteMap.Profile: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .themeChange:
            navi.push(content: ThemeChangeView())
        case .developer:
            navi.push(content: DeveloperModeView())
        case .about:
            navi.push(content: AboutView())
        case .addressBook:
            navi.push(content: AddressBookView())
        case .edit:
            navi.push(content: ProfileEditView())
        case .editName:
            navi.push(content: ProfileEditNameView())
        case .editAvatar:
            navi.push(content: EditAvatarView())
        case .backupChange:
            #if DEBUG
//            navi.push(content: BackupPatternView())
//            return
            #endif
            if let existVC = navi.viewControllers.first(where: { $0.navigationItem.title == "backup".localized }) {
                navi.popToViewController(existVC, animated: true)
                return
            }

            navi.push(content: ProfileBackupView())
        case .walletSetting(let animated, let address):
            Router.coordinator.rootNavi?.push(content: WalletSettingView(address: address), animated: animated)
        case .walletConnect:
            navi.push(content: WalletConnectView())
        case .privateKey(let animated):
            Router.coordinator.rootNavi?.push(content: PrivateKeyView(), animated: animated)
        case .manualBackup(let animated):
            Router.coordinator.rootNavi?.push(content: RecoveryPhraseView(backupMode: true), animated: animated)
        case .security(let animated):
            if let existVC = Router.coordinator.rootNavi?.viewControllers.first(where: { $0.navigationItem.title == "security".localized }) {
                navi.popToViewController(existVC, animated: animated)
                return
            }

            Router.coordinator.rootNavi?.push(content: ProfileSecureView(), animated: animated)
        case .inbox:
            navi.push(content: InboxView())
        case .resetWalletConfirm:
            navi.push(content: WalletResetConfirmView())
        case .currency:
            navi.push(content: CurrencyListView())
        case .accountSetting:
            navi.push(content: AccountSettingView())
        case .accountDetail(let childAccount):
            let vm = ChildAccountDetailViewModel(childAccount: childAccount)
            navi.push(content: ChildAccountDetailView(vm: vm))
        case .switchProfile:
            let vc = CustomHostingController(rootView: AccountSwitchView(), showLarge: true)
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .editChildAccount(let childAccount):
            let vm = ChildAccountDetailEditViewModel(childAccount: childAccount)
            navi.push(content: ChildAccountDetailEditView(vm: vm))
        case .backToAccountSetting:
            if let existVC = navi.viewControllers.first(where: { $0 as? RouteableUIHostingController<AccountSettingView> != nil }) {
                navi.popToViewController(existVC, animated: true)
                return
            }
            navi.popToRootViewController(animated: true)
        case .linkedAccount:
            navi.push(content: LinkedAccountView())
        case .accountKeys:
            navi.push(content: AccountKeysView())
        case .devices:
            navi.push(content: DevicesView())
        case .deviceInfo(let model):
            navi.push(content: DevicesInfoView(info: model))
        case .keychain:
            navi.push(content: KeychainListView())
            
        case .walletList:
            navi.push(content: WalletListView())
        }
    }
}

// MARK: - AddressBook

extension RouteMap {
    enum AddressBook {
        case root
        case add(AddressBookView.AddressBookViewModel)
        case edit(Contact, AddressBookView.AddressBookViewModel)
        case pick(WalletSendView.WalletSendViewSelectTargetCallback)
    }
}

extension RouteMap.AddressBook: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: AddressBookView())
        case .add(let vm):
            navi.push(content: AddAddressView(addressBookVM: vm))
        case .edit(let contact, let vm):
            navi.push(content: AddAddressView(editingContact: contact, addressBookVM: vm))
        case .pick(let callback):
            navi.present(content: WalletSendView(callback: callback))
        }
    }
}

// MARK: - PinCode

extension RouteMap {
    enum PinCode {
        case root
        case pinCode
        case confirmPinCode(String)
        case verify(Bool, Bool, VerifyPinViewModel.VerifyCallback)
    }
}

extension RouteMap.PinCode: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: RequestSecureView())
        case .pinCode:
            navi.push(content: CreatePinCodeView())
        case .confirmPinCode(let lastPin):
            navi.push(content: ConfirmPinCodeView(lastPin: lastPin))
        case .verify(let animated, let needNavi, let callback):
            let vc = RouteableUIHostingController(rootView: VerifyPinView(callback: callback))
            vc.modalPresentationStyle = .fullScreen
            if needNavi {
                let contentNavi = RouterNavigationController(rootViewController: vc)
                contentNavi.modalPresentationCapturesStatusBarAppearance = true
                contentNavi.modalPresentationStyle = .fullScreen
                Router.topPresentedController().present(contentNavi, animated: animated)
            } else {
                Router.topPresentedController().present(vc, animated: animated)
            }
        }
    }
}

// MARK: - NFT

extension RouteMap {
    enum NFT {
        case detail(NFTTabViewModel, NFTModel, Bool)
        case collection(NFTTabViewModel, CollectionItem)
        case collectionDetail(String, String, Bool)
        case addCollection
        case send(NFTModel, Contact)
        case AR(UIImage)
        case selectCollection(SelectCollectionViewModel)
    }
}

extension RouteMap.NFT: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .detail(let vm, let nft, let fromLinkedAccount):
            navi.push(content: NFTDetailPage(viewModel: vm, nft: nft, from: fromLinkedAccount))
        case .collection(let vm, let collection):
            navi.push(content: NFTCollectionListView(viewModel: vm, collection: collection))
        case .collectionDetail(let addr, let path, let fromLinkedAccount):
            navi.push(content: NFTCollectionListView(address: addr, path: path, from: fromLinkedAccount))
        case .addCollection:
            navi.push(content: NFTAddCollectionView())
        case .send(let nft, let contact):
            let vc = CustomHostingController(rootView: NFTTransferView(nft: nft, target: contact))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .AR:
            print("")
        case .selectCollection(let vm):
            navi.present(content: SelectCollectionView(viewModel: vm))
        }
    }
}

// MARK: - Transaction

extension RouteMap {
    enum Transaction {
        case detail(Flow.ID)
    }
}

extension RouteMap.Transaction: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .detail(let transactionId):
            if let url = transactionId.transactionFlowScanURL {
//                UIApplication.shared.open(url)
                TransactionUIHandler.shared.dismissListView()
                Router.route(to: RouteMap.Explore.browser(url))
            }
        }
    }
}

// MARK: - Explore

extension RouteMap {
    enum Explore {
        case browser(URL)
        case safariBrowser(URL)
        case authn(BrowserAuthnViewModel)
        case authz(BrowserAuthzViewModel)
        case signMessage(BrowserSignMessageViewModel)
        case searchExplore
        case claimDomain
        case bookmark
        case linkChildAccount(ChildAccountLinkViewModel)
        case dapps
        case switchNetwork(LocalUserDefaults.FlowNetworkType, LocalUserDefaults.FlowNetworkType)
    }
}

extension RouteMap.Explore: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .browser(let url):
            if let isIn = RemoteConfigManager.shared.config?.features.browser, isIn{
                let vc = BrowserViewController()
                vc.loadURL(url)
                navi.pushViewController(vc, animated: true)
            }else {
                UIApplication.shared.open(url)
            }
            
        case .safariBrowser(let url):
            let vc = SFSafariViewController(url: url)
            navi.present(vc, animated: true)
        case .authn(let vm):
            let vc = CustomHostingController(rootView: BrowserAuthnView(vm: vm))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .authz(let vm):
            let vc = CustomHostingController(rootView: BrowserAuthzView(vm: vm), showLarge: true)
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .signMessage(let vm):
            let vc = CustomHostingController(rootView: BrowserSignMessageView(vm: vm), showLarge: true)
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .searchExplore:
            let inputVC = BrowserSearchInputViewController()
            inputVC.setSearchText(text: "")
            inputVC.selectTextCallback = { text in
                UISelectionFeedbackGenerator().selectionChanged()
                let urlString = BrowserSearchInputViewController.makeUrlIfNeeded(urlString: text)
                if let url = URL(string: urlString) {
                    navi.popViewController(animated: false) {
                        Router.route(to: RouteMap.Explore.browser(url))
                    }
                }
            }
            navi.pushViewController(inputVC, animated: false)
        case .claimDomain:
            navi.push(content: ClaimDomainView())
        case .bookmark:
            navi.present(content: BrowserBookmarkView())
        case .linkChildAccount(let vm):
            let vc = CustomHostingController(rootView: ChildAccountLinkView(vm: vm))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case .dapps:
            navi.present(content: DAppsListView())
        case .switchNetwork(let from, let to):
            let vc = CustomHostingController(rootView: NetworkSwitchPopView(from: from, to: to))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        }
    }
}
