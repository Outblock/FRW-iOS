//
//  NFTTransferView.swift
//  Flow Wallet
//
//  Created by Selina on 25/8/2022.
//

import SwiftUI
import Kingfisher
import Flow
import web3swift
import Web3Core

class NFTTransferViewModel: ObservableObject {
    @Published var nft: NFTModel
    @Published var targetContact: Contact
    @Published var isValidNFT = true
    @Published var isEmptyTransation = true
    
    private var isRequesting: Bool = false
    
    init(nft: NFTModel, targetContact: Contact) {
        self.nft = nft
        self.targetContact = targetContact
        checkNFTReachable()
        NotificationCenter.default.addObserver(self, selector: #selector(onHolderChanged(noti:)), name: .transactionStatusDidChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkNFTReachable() {
        Task {
            guard let toAddress = targetContact.address, let collection = nft.collection else {
                return
            }

            let result = try await FlowNetwork.checkCollectionEnable(address: Flow.Address(hex: toAddress), list: [collection])
            self.isValidNFT = result.first ?? false;
        }
    }
    
    func sendAction() {
        if TransactionManager.shared.isNFTTransfering(id: nft.id) {
            // TODO: show bottom sheet
            return
        }
        
        if SecurityManager.shared.securityType == .none {
            sendLogic()
            return
        }
        
        Task {
            let result = await SecurityManager.shared.inAppVerify()
            if result {
                sendLogic()
            }
        }
    }
    
    func sendLogic() {
        enum AccountType {
            case flow
            case coa
            case eoa
        }
        
        if isRequesting {
            return
        }
        
        guard let toAddress = targetContact.address, let fromAddress = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        
        let failedBlock = {
            DispatchQueue.main.async {
                self.isRequesting = false
                HUD.error(title: "send_nft_failed".localized)
            }
        }
        
        self.isRequesting = true
        
        
        Task {
            do {
                let fromAccountType = WalletManager.shared.isSelectedEVMAccount ? AccountType.coa : AccountType.flow
                var toAccountType = toAddress.isEVMAddress ? AccountType.coa : AccountType.flow
                if toAccountType == .coa && toAddress != EVMAccountManager.shared.accounts.first?.address {
                    toAccountType = .eoa
                }
                var tid: Flow.ID?
                switch (fromAccountType, toAccountType) {
                case (.flow, .flow):
                    tid = try await FlowNetwork.transferNFT(to: Flow.Address(hex: toAddress), nft: nft)
                case (.flow, .eoa):
                    log.debug("[NFT] flow to eoa send")
                    let erc20Contract = try await FlowProvider.Web3.defaultContract()
                    let nftId = nft.response.id
                    guard let nftAddress = self.nft.collection?.address, let nftName = nft.collection?.contractName,
                          let collectionName = nft.collection?.contractName,
                          let data = erc20Contract?.contract.method("transfer", parameters: [toAddress, Utilities.parseToBigUInt(String(nftId), units: .ether)!], extraData: nil)
                    else {
                        throw NFTError.sendInvalidAddress
                    }
                    
                    tid = try await FlowNetwork.bridgeNFTToAnyEVM(nftContractAddress: nftAddress, nftContractName: nftName, id: nftId, tokenContractName: collectionName, contractEVMAddress: toAddress.stripHexPrefix(), data: data, gas: 100000)
                case (.coa, .flow):
                    if fromAddress == toAddress {
                        
                    }else {
                        
                    }
                    let nftId = nft.response.id
                    guard let nftAddress = self.nft.collection?.address, let nftName = nft.collection?.contractName,
                          let collectionName = nft.collection?.contractName
                    else {
                        throw NFTError.sendInvalidAddress
                    }
                    tid = try await FlowNetwork.bridgeNFTFromEVMToAnyFlow(nftContractAddress: nftAddress, nftContractName: nftName, id: nftId, receiver: toAddress)
                    
                default:
                    failedBlock()
                    return
                }
                
                
                
                
                let model = NFTTransferModel(nft: nft, target: self.targetContact, from: fromAddress)
                guard let data = try? JSONEncoder().encode(model), let tid = tid else {
                    failedBlock()
                    return
                }
                
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    Router.dismiss()
                    let holder = TransactionManager.TransactionHolder(id: tid, type: .transferNFT, data: data)
                    TransactionManager.shared.newTransaction(holder: holder)
                }
            } catch {
                debugPrint("NFTTransferViewModel -> sendAction error: \(error)")
                self.isRequesting = false
                failedBlock()
            }
        }
    }
    
    func checkTransaction() {
        isEmptyTransation = TransactionManager.shared.holders.count == 0
    }
 
    @objc private func onHolderChanged(noti: Notification) {
        checkTransaction()
    }
}

struct NFTTransferView: View {
    @StateObject var vm: NFTTransferViewModel
    
    init(nft: NFTModel, target: Contact) {
        _vm = StateObject(wrappedValue: NFTTransferViewModel(nft: nft, targetContact: target))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SheetHeaderView(title: "send_nft".localized)
            
            VStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    fromToView
                    NFTTransferView.SendConfirmProgressView()
                        .padding(.bottom, 37)
                }
                
                detailView
                    .padding(.top, 37)
                CalloutView(corners: [.bottomLeading, .bottomTrailing] ,content: "nft_send_collection_empty".localized)
                    .padding(.horizontal, 12)
                    .visibility(vm.isValidNFT ? .gone : .visible)
                    .transition(.move(edge: .top))
                
                Spacer()
                
                sendButton
            }
            .padding(.horizontal, 28)
        }
        .backgroundFill(Color.LL.Neutrals.background)
    }

    var fromToView: some View {
        HStack(spacing: 16) {
            contactView(contact: UserManager.shared.userInfo!.toContactWithCurrentUserAddress())
            Spacer()
            contactView(contact: vm.targetContact)
        }
    }

    func contactView(contact: Contact) -> some View {
        VStack(spacing: 5) {
            // avatar
            ZStack {
                if let avatar = contact.avatar?.convertedAvatarString(), avatar.isEmpty == false {
                    KFImage.url(URL(string: avatar))
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                } else if contact.needShowLocalAvatar {
                    Image(contact.localAvatar ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                } else {
                    Text(String((contact.contactName?.first ?? "A").uppercased()))
                        .foregroundColor(.LL.Primary.salmonPrimary)
                        .font(.inter(size: 24, weight: .semibold))
                }
            }
            .frame(width: 44, height: 44)
            .background(.LL.Primary.salmon5)
            .clipShape(Circle())

            // contact name
            Text(contact.contactName ?? "name")
                .foregroundColor(.LL.Neutrals.neutrals1)
                .font(.inter(size: 14, weight: .semibold))
                .lineLimit(1)

            // address
            Text(contact.address ?? "0x")
                .foregroundColor(.LL.Neutrals.note)
                .font(.inter(size: 12, weight: .regular))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    var detailView: some View {
        HStack(alignment: .center, spacing: 13) {
            KFImage.url(vm.nft.imageURL)
                .placeholder({
                    Image("placeholder")
                        .resizable()
                })
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 72, height: 72)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(vm.nft.title)
                    .foregroundColor(.LL.Neutrals.text)
                    .font(.inter(size: 14, weight: .bold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    KFImage.url(vm.nft.collection?.logoURL)
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 20, height: 20)
                        .cornerRadius(10)
                    
                    Text(vm.nft.collection?.name ?? "")
                        .foregroundColor(.LL.Neutrals.neutrals7)
                        .font(.inter(size: 14, weight: .regular))
                    
                    Image("flow")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 12, height: 12)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(Color.LL.bgForIcon)
        .cornerRadius(16)
    }
    
    var sendButton: some View {
        WalletSendButtonView(allowEnable: $vm.isEmptyTransation) {
            if vm.isEmptyTransation {
                vm.sendAction()
            }
            
        }
    }
    
    struct SendConfirmProgressView: View {
        private let totalNum: Int = 7
        @State private var step: Int = 0
        private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

        var body: some View {
            HStack(spacing: 12) {
                ForEach(0..<totalNum, id: \.self) { index in
                    if step == index {
                        Image("icon-right-arrow-1")
                            .renderingMode(.template)
                            .foregroundColor(.LL.Primary.salmonPrimary)
                    } else {
                        switch index {
                        case 0:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmon5)
                        case 1:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmon4)
                        case 2:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmon3)
                        default:
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(.LL.Primary.salmonPrimary)
                        }
                    }
                }
            }
            .onReceive(timer) { _ in
                DispatchQueue.main.async {
                    if step < totalNum - 1 {
                        step += 1
                    } else {
                        step = 0
                    }
                }
            }
        }
    }
}
