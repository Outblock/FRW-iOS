//
//  RouterMap.swift
//  Lilico
//
//  Created by Selina on 25/7/2022.
//

import UIKit
import SwiftUI
import SwiftUIX
import Flow
import SafariServices

enum RouteMap {
    
}

// MARK: - Restore Login

extension RouteMap {
    enum RestoreLogin {
        case root
        case restoreManual
        case chooseAccount([BackupManager.DriveItem])
        case enterRestorePwd(BackupManager.DriveItem)
    }
}

extension RouteMap.RestoreLogin: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root:
            navi.push(content: RestoreWalletView())
        case .restoreManual:
            navi.push(content: InputMnemonicView())
        case .chooseAccount(let items):
            navi.push(content: ChooseAccountView(driveItems: items))
        case .enterRestorePwd(let item):
            navi.push(content: EnterRestorePasswordView(driveItem: item))
        }
    }
}

// MARK: - Register

extension RouteMap {
    enum Register {
        case root(String?)
        case username(String?)
        case tynk(String, String?)
    }
}

extension RouteMap.Register: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .root(let mnemonic):
            navi.push(content: TermsAndPolicy(mnemonic: mnemonic))
        case .username(let mnemonic):
            navi.push(content: UsernameView(mnemonic: mnemonic))
        case .tynk(let username, let mnemonic):
            navi.push(content: TYNKView(username: username, mnemonic: mnemonic))
        }
    }
}

// MARK: - Backup

extension RouteMap {
    enum Backup {
        case rootWithMnemonic
        case backupToCloud(BackupManager.BackupType)
        case backupManual
    }
}

extension RouteMap.Backup: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .rootWithMnemonic:
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
        }
    }
}

// MARK: - Wallet

extension RouteMap {
    enum Wallet {
        case addToken
        case tokenDetail(TokenModel)
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
    }
}

extension RouteMap.Wallet: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .addToken:
            navi.push(content: AddTokenView(vm: AddTokenViewModel()))
        case .tokenDetail(let token):
            navi.push(content: TokenDetailView(token: token))
        case .receive:
            let vc = UIHostingController(rootView: WalletReceiveView())
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .coverVertical
            vc.view.backgroundColor = .clear
            navi.present(vc, animated: false)
        case let .send(address):
            navi.present(content: WalletSendView(address: address))
        case let .sendAmount(contact, token, isPush):
            if isPush {
                navi.push(content: WalletSendAmountView(target: contact, token: token))
            } else {
                navi.present(content: WalletSendAmountView(target: contact, token: token))
            }
        case let .scan(handler, click):
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
        case walletSetting(Bool)
        case privateKey(Bool)
        case walletConnect
        case manualBackup(Bool)
        case security(Bool)
        case inbox
        case resetWalletConfirm
        case currency
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
            if let existVC = navi.viewControllers.first(where: { $0.navigationItem.title == "backup".localized }) {
                navi.popToViewController(existVC, animated: true)
                return
            }
            
            navi.push(content: ProfileBackupView())
        case .walletSetting(let animated):
            Router.coordinator.rootNavi?.push(content: WalletSettingView(), animated: animated)
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
        case detail(NFTTabViewModel, NFTModel)
        case collection(NFTTabViewModel, CollectionItem)
        case addCollection
        case send(NFTModel, Contact)
        case AR(UIImage)
    }
}

extension RouteMap.NFT: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case .detail(let vm, let nft):
            navi.push(content: NFTDetailPage(viewModel: vm, nft: nft))
        case .collection(let vm, let collection):
            navi.push(content: NFTCollectionListView(viewModel: vm, collection: collection))
        case .addCollection:
            navi.push(content: NFTAddCollectionView())
        case .send(let nft, let contact):
            let vc = CustomHostingController(rootView: NFTTransferView(nft: nft, target: contact))
            Router.topPresentedController().present(vc, animated: true, completion: nil)
        case let .AR(image):
            let vc = ARViewController()
            vc.image = image
            navi.pushViewController(vc)
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
    }
}

extension RouteMap.Explore: RouterTarget {
    func onPresent(navi: UINavigationController) {
        switch self {
        case let .browser(url):
            let vc = BrowserViewController()
            vc.loadURL(url)
            navi.pushViewController(vc, animated: true)
        case let .safariBrowser(url):
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
        }
    }
}
