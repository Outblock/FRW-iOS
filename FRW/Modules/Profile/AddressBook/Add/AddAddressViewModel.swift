//
//  AddAddressViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 1/6/2022.
//

import Foundation
import Web3Core

extension AddAddressView {
    enum AddressStateType {
        case idle
        case checking
        case passed
        case invalidFormat
        case notFound

        // MARK: Internal

        var desc: String {
            switch self {
            case .invalidFormat:
                return "invalid_address".localized
            case .notFound:
                return "can_not_find_address".localized
            default:
                return ""
            }
        }
    }

    struct AddAddressState {
        var name: String = "" {
            didSet {
                refreshReadyFlag()
            }
        }

        var address: String = ""

        var addressStateType: AddressStateType = .idle {
            didSet {
                refreshReadyFlag()
            }
        }

        var isReadyForSave = false

        var isEditingMode = false
        var editingContact: Contact?

        private mutating func refreshReadyFlag() {
            let finalName = name.trim()
            let finalAddress = address.trim().lowercased()

            if finalName.isEmpty {
                isReadyForSave = false
                return
            }

            if addressStateType != .passed {
                isReadyForSave = false
                return
            }

            if isEditingMode {
                if finalName == editingContact?.contactName,
                   finalAddress == editingContact?.address {
                    isReadyForSave = false
                    return
                }
            }

            isReadyForSave = true
        }
    }

    enum AddAddressInput {
        case checkAddress
        case save
    }

    final class AddAddressViewModel: ViewModel {
        // MARK: Lifecycle

        init(addressBookVM: AddressBookView.AddressBookViewModel) {
            self.state = AddAddressState()
            self.addressBookVM = addressBookVM
        }

        init(contact: Contact, addressBookVM: AddressBookView.AddressBookViewModel) {
            self.addressBookVM = addressBookVM

            self.state = AddAddressState()
            state.isEditingMode = true
            state.editingContact = contact
            state.name = contact.contactName ?? ""
            state.address = contact.address ?? ""

            trigger(.checkAddress)
        }

        // MARK: Internal

        enum AddressType {
            case flow, evm
        }

        @Published
        var state: AddAddressState

        func trigger(_ input: AddAddressInput) {
            switch input {
            case .checkAddress:
                checkAddressAction()
            case .save:
                saveAction()
            }
        }

        // MARK: Private

        private var addressBookVM: AddressBookView.AddressBookViewModel

        private var addressCheckTask: DispatchWorkItem?

        private func saveAction() {
            if checkContactExists() == true {
                HUD.error(title: "contact_exists".localized)
                return
            }

            if state.isEditingMode {
                editContactAction()
                return
            }

            addContactAction()
        }

        private func addContactAction() {
            HUD.loading("saving".localized)
            let contactName = state.name.trim()
            let address = state.address.trim().lowercased()

            let errorAction = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    HUD.error(title: "request_failed".localized)
                }
            }

            let successAction = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    NotificationCenter.default.post(name: .addressBookDidAdd, object: nil)
                    Router.pop()
                    HUD.success(title: "contact_added".localized)
                }
            }

            Task {
                do {
                    let request = AddressBookAddRequest(
                        contactName: contactName,
                        address: address,
                        domain: "",
                        domainType: .unknown,
                        username: ""
                    )
                    let response: Network.EmptyResponse = try await Network
                        .requestWithRawModel(FRWAPI.AddressBook.addExternal(request))

                    if response.httpCode != 200 {
                        errorAction()
                        return
                    }

                    successAction()
                } catch {
                    errorAction()
                }
            }
        }

        private func editContactAction() {
            HUD.loading("saving".localized)
            let contactName = state.name.trim()
            let address = state.address.trim().lowercased()

            let errorAction = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    HUD.error(title: "request_failed".localized)
                }
            }

            let successAction = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    NotificationCenter.default.post(name: .addressBookDidEdit, object: nil)
                    Router.pop()
                    HUD.success(title: "contact_edited".localized)
                }
            }

            Task {
                do {
                    guard let id = state.editingContact?.id,
                          let domainType = state.editingContact?.domain?.domainType
                    else {
                        errorAction()
                        return
                    }

                    let request = AddressBookEditRequest(
                        id: id,
                        contactName: contactName,
                        address: address,
                        domain: "",
                        domainType: domainType,
                        username: ""
                    )
                    let response: Network.EmptyResponse = try await Network
                        .requestWithRawModel(FRWAPI.AddressBook.edit(request))

                    if response.httpCode != 200 {
                        errorAction()
                        return
                    }

                    successAction()
                } catch {
                    errorAction()
                }
            }
        }

        private func checkContactExists() -> Bool {
            let contactName = state.name.trim()
            let address = state.address.trim().lowercased()
            let domain = Contact.Domain(domainType: .unknown, value: "")
            let contact = Contact(
                address: address,
                avatar: nil,
                contactName: contactName,
                contactType: .external,
                domain: domain,
                id: 0,
                username: ""
            )

            return addressBookVM.contactIsExists(contact)
        }

        private func checkAddressAction() {
            cancelCurrentAddressCheckTask()

            if state.address.isEmpty {
                state.addressStateType = .idle
                return
            }

            let formattedAddress = state.address.trim().lowercased().addHexPrefix()

            switch checkAddressFormat(formattedAddress) {
            case .some(.flow):
                delayCheckAddressExists(formattedAddress)
            case .some(.evm):
                checkEoaAddressExists(formattedAddress)
            case .none:
                state.addressStateType = .invalidFormat
            }
        }
    }
}

extension AddAddressView.AddAddressViewModel {
    private func checkAddressFormat(_ address: String) -> AddressType? {
        if address.matchRegex("^0x[a-fA-F0-9]{16}$") {
            return .flow
        }

        if address.matchRegex("^0x[0-9a-fA-F]{40}$") {
            return .evm
        }

        return nil
    }

    private func delayCheckAddressExists(_ address: String) {
        state.addressStateType = .idle

        let task = DispatchWorkItem { [weak self] in
            guard let self = self else {
                return
            }

            self.state.addressStateType = .checking

            Task {
                let exist = await FlowNetwork.addressVerify(address: address)
                DispatchQueue.main.async {
                    self.state.addressStateType = exist ? .passed : .notFound
                }
            }
        }
        addressCheckTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }

    private func checkEoaAddressExists(_ address: String) {
        guard let eoa = EthereumAddress(address, type: .normal, ignoreChecksum: true) else {
            state.addressStateType = .invalidFormat
            return
        }

        guard eoa.isValid else {
            state.addressStateType = .invalidFormat
            return
        }

        state.addressStateType = .passed
    }

    private func cancelCurrentAddressCheckTask() {
        if let task = addressCheckTask {
            task.cancel()
            addressCheckTask = nil
        }
    }
}
