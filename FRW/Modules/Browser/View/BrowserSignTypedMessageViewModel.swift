//
//  BrowserSignTypedMessageViewModel.swift
//  FRW
//
//  Created by cat on 2024/10/8.
//

import Foundation

class BrowserSignTypedMessageViewModel: ObservableObject {
    
    typealias Callback = (Bool) -> Void
    
    @Published var title: String
    @Published var urlString: String
    @Published var logo: String?
    @Published var rawString: String
    
    @Published var sections: [BrowserSignTypedMessageViewModel.Section] = []
    
    @Published var list: [JSONValue] = []
    
    private var callback: BrowserSignTypedMessageViewModel.Callback?
    
    init(title: String, urlString: String, logo: String? = nil, rawString: String, callback: BrowserSignTypedMessageViewModel.Callback? = nil) {
        self.title = title
        self.urlString = urlString
        self.logo = logo
        self.rawString = rawString
        self.callback = callback
        parseRawString()
    }
    
    private func parseRawString() {
        guard let data = rawString.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = object as? [String: Any]
        else {
            return
        }
        let primaryType = (dict["primaryType"] as? String) ?? ""
        let headerSection = Section(title: "Message", content: nil, items: [.init(tag: "Primary Type", content: primaryType)])
        self.sections.append(headerSection)
        
        guard let message = dict["message"] as? [String: Any] else {
            return
        }
        var tmpSection: [Section] = []
        
        let result = JSONValue.parse(jsonString: rawString)
        switch result {
        case .object(let dictionary):
            for (key, value) in dictionary {
                if key.lowercased() == "primaryType".lowercased() {
                    list.insert(JSONValue.object( ["Message": JSONValue.object([key: value])]), at: 0)
                }else if key.lowercased() == "message" {
                    if case .object(let mDic) = value {
                        for (mKey, mValue) in mDic {
                            list.append(JSONValue.object([mKey : mValue]))
                        }
                    }
                }
            }
        default:
            break
        
        }
        log.debug(result ?? "")
        
        for (key, value) in message {
            if let item = value as? [String: String] {
                var items: [Section.Item] = []
                for (itemKey, itemValue) in item {
                    let tmpItem = Section.Item(tag: itemKey, content: itemValue)
                    items.append(tmpItem)
                }
                let section = Section(title: key, content: nil, items: items)
                tmpSection.append(section)
            }
            else if let item = value as? String {
                let section = Section(title: key, content: item, items: [])
                tmpSection.append(section)
            }
        }
        self.sections.append(contentsOf: tmpSection)
    }
    
    func didChooseAction(_ result: Bool) {
        callback?(result)
        callback = nil
        Router.dismiss()
    }
    
    func onCloseAction() {
        callback?(false)
        callback = nil
        Router.dismiss()
    }
    
    deinit {
        callback?(false)
        WalletConnectManager.shared.reloadPendingRequests()
    }
}

extension BrowserSignTypedMessageViewModel {
    struct Section {
        struct Item {
            let tag: String
            let content: String
        }
        
        let title: String
        let content: String?
        let items: [Section.Item]
        
        func showTitle() -> String {
            let tit = title.uppercasedFirstLetter()
            if !tit.hasPrefix(":") {
                return tit + ":"
            }
            return tit
        }
    }
    
}
