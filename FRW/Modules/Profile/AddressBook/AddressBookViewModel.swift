//
//  AddressBookViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 24/5/2022.
//


import SwiftUI
import Combine

// MARK: - Define

extension AddressBookView {
    struct SectionState: Identifiable {
        var sectionName: String
        var list: [Contact]

        var id: String {
            return sectionName
        }
    }

    class SectionViewModel: ViewModel, Identifiable, Indexable {
        @Published var state: SectionState

        var id: String {
            return state.id
        }

        var index: Index? {
            return Index(state.sectionName, contentID: state.id)
        }

        init(sectionName: String, list: [Contact]) {
            state = SectionState(sectionName: sectionName, list: list)
        }

        func trigger(_: Never) {}
    }
}

extension AddressBookView {
    enum AddressBookViewStateType {
        case idle
        case loading
        case error
    }

    struct ListState {
        var sections: [AddressBookView.SectionViewModel]
        var stateType: AddressBookViewStateType = .loading
    }

    enum AddressBookInput {
        case load
        case delete(AddressBookView.SectionViewModel, Contact)
        case edit(Contact)
        case select(Contact)
    }
}

// MARK: - Implementation

extension AddressBookView {
    class AddressBookViewModel: ViewModel {
        @Published var state: ListState
        @Published var searchText: String = ""
        
        var injectSelectAction: ((Contact) -> Void)?
        
        private var rawContacts: [Contact]?
        private var cancelSets = Set<AnyCancellable>()
        private let cacheKey = "AddressBookViewContacts"

        init() {
            state = ListState(sections: [AddressBookView.SectionViewModel]())
            
            loadFromCache()
            trigger(.load)
            
            registerNotifications()
        }
        
        private func registerNotifications() {
            NotificationCenter.default.publisher(for: .addressBookDidAdd).sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.trigger(.load)
                }
            }.store(in: &cancelSets)
            
            NotificationCenter.default.publisher(for: .addressBookDidEdit).sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.trigger(.load)
                }
            }.store(in: &cancelSets)
        }

        func trigger(_ input: AddressBookView.AddressBookInput) {
            switch input {
            case .load:
                load()
            case let .delete(sectionVM, contact):

                delete(sectionVM: sectionVM, contact: contact)
            case let .edit(contact):
                editContact(contact)
            case let .select(contact):
                selectContact(contact)
            }
        }

        func contactIsExists(_ contact: Contact) -> Bool {
            for sectionVM in state.sections {
                for tempContact in sectionVM.state.list {
                    if tempContact.contactName == contact.contactName,
                       tempContact.address == contact.address,
                       tempContact.contactType == contact.contactType,
                       tempContact.domain?.domainType == contact.domain?.domainType,
                       tempContact.username == contact.username
                    {
                        return true
                    }
                }
            }

            return false
        }

        private func trimListModels() {
            state.sections = state.sections.filter { svm in
                svm.state.list.isEmpty == false
            }
        }

        private func editContact(_ contact: Contact) {
            searchText = ""
            Router.route(to: RouteMap.AddressBook.edit(contact, self))
        }

        private func delete(sectionVM: AddressBookView.SectionViewModel, contact: Contact) {
            searchText = ""

            guard let realSectionVM = state.sections.first(where: { svm in
                svm.id == sectionVM.id
            }) else {
                return
            }

            guard let index = realSectionVM.state.list.firstIndex(where: { c in
                c.id == contact.id
            }) else {
                return
            }

            HUD.loading("deleting".localized)

            let successAction = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    realSectionVM.state.list.remove(at: index)
                    self.trimListModels()
                    self.saveCurrentGroupedListToCache()
                    HUD.success(title: "contact_deleted".localized)
                }
            }

            let failedAction = {
                DispatchQueue.main.async {
                    HUD.dismissLoading()
                    HUD.error(title: "delete_failed".localized)
                }
            }

            Task {
                do {
                    let response: Network.EmptyResponse = try await Network.requestWithRawModel(FRWAPI.AddressBook.delete(contact.id))

                    if response.httpCode != 200 {
                        failedAction()
                        return
                    }

                    successAction()
                } catch {
                    failedAction()
                }
            }
        }
        
        private func selectContact(_ contact: Contact) {
            if let action = injectSelectAction {
                action(contact)
            }
        }

        private func load() {
            state.stateType = .loading

            Task {
                do {
                    let response: AddressListBookResponse = try await Network.request(FRWAPI.AddressBook.fetchList)
                    DispatchQueue.main.async {
                        self.rawContacts = response.contacts
                        self.saveToCache(contacts: response.contacts)
                        
                        self.regroup(response.contacts)
                        self.state.stateType = .idle
                    }
                } catch {
                    DispatchQueue.main.async {
                        if self.state.stateType == .idle {
                            HUD.error(title: "request_failed".localized)
                            return
                        }
                        
                        self.state.stateType = .error
                    }
                }
            }
        }

        private func regroup(_ contacts: [Contact]?) {
            var rawContacts = contacts
            if rawContacts == nil {
                rawContacts = []
            }

            BMChineseSort.share.compareTpye = .fullPinyin
            BMChineseSort.sortAndGroup(objectArray: rawContacts, key: "contactName") { success, _, sectionTitleArr, sortedObjArr in
                if !success {
                    self.state.stateType = .error
                    return
                }

                var sections = [AddressBookView.SectionViewModel]()
                for (index, title) in sectionTitleArr.enumerated() {
                    let svm = AddressBookView.SectionViewModel(sectionName: title, list: sortedObjArr[index])
                    sections.append(svm)
                }

                self.state.sections = sections
            }
        }
    }
}

// MARK: - Cache

extension AddressBookView.AddressBookViewModel {
    private func saveToCache(contacts: [Contact]?) {
        if let contacts = contacts {
            PageCache.cache.set(value: contacts, forKey: cacheKey)
        } else {
            PageCache.cache.set(value: [Contact](), forKey: cacheKey)
        }
    }
    
    private func loadFromCache() {
        Task {
            if let cacheContacts = try? await PageCache.cache.get(forKey: cacheKey, type: [Contact].self), !cacheContacts.isEmpty {
                DispatchQueue.main.async {
                    self.rawContacts = cacheContacts
                    self.regroup(cacheContacts)
                    self.state.stateType = .idle
                }
            }
        }
    }
    
    private func saveCurrentGroupedListToCache() {
        var contacts = [Contact]()
        
        for section in state.sections {
            contacts.append(contentsOf: section.state.list)
        }
        
        saveToCache(contacts: contacts)
    }
}

// MARK: - Search

extension AddressBookView.AddressBookViewModel {
    var searchResults: [AddressBookView.SectionViewModel] {
        if searchText.isEmpty {
            return state.sections
        }

        var searchSections: [AddressBookView.SectionViewModel] = []

        for section in state.sections {
            var contacts = [Contact]()

            for contact in section.state.list {
                if let address = contact.address, address.localizedCaseInsensitiveContains(searchText) {
                    contacts.append(contact)
                    continue
                }

                if let contactName = contact.contactName, contactName.localizedCaseInsensitiveContains(searchText) {
                    contacts.append(contact)
                    continue
                }

                if let userName = contact.username, userName.localizedCaseInsensitiveContains(searchText) {
                    contacts.append(contact)
                    continue
                }
            }

            if contacts.count > 0 {
                let newSection = AddressBookView.SectionViewModel(sectionName: section.state.sectionName, list: contacts)
                searchSections.append(newSection)
            }
        }

        return searchSections
    }
}

// MARK: - Extra

extension AddressBookView.AddressBookViewModel {
    /// search from send view
    func searchLocal(text: String) -> [WalletSendView.SearchSection] {
        var results = [WalletSendView.SearchSection]()
        
        for section in state.sections {
            var contacts = [Contact]()

            for contact in section.state.list {
                if let address = contact.address, address.localizedCaseInsensitiveContains(text) {
                    contacts.append(contact)
                    continue
                }

                if let contactName = contact.contactName, contactName.localizedCaseInsensitiveContains(text) {
                    contacts.append(contact)
                    continue
                }

                if let userName = contact.username, userName.localizedCaseInsensitiveContains(text) {
                    contacts.append(contact)
                    continue
                }
            }

            if contacts.count > 0 {
                let newSection = WalletSendView.SearchSection(title: section.state.sectionName, rows: contacts)
                results.append(newSection)
            }
        }
        
        return results
    }
    
    func isFriend(contact: Contact) -> Bool {
        for tempContact in rawContacts ?? [] {
            if tempContact.uniqueId == contact.uniqueId {
                return true
            }
        }
        
        return false
    }
    
    func appendNewContact(contact: Contact) {
        rawContacts?.append(contact)
        
        saveToCache(contacts: rawContacts)
        
        regroup(rawContacts)
        state.stateType = .idle
    }
}
