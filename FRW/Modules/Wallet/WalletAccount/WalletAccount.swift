//
//  WalletAccount.swift
//  FRW
//
//  Created by cat on 2024/5/20.
//

import Foundation
import SwiftUI

struct WalletAccount {
    
    var storedAccount: [String: [WalletAccount.User]]
    
    private var key: String {
        guard let userId = UserManager.shared.activatedUID else {
            return "empty"
        }
        return "\(userId)"
    }

    
    init() {
        self.storedAccount = LocalUserDefaults.shared.walletAccount ?? [:]
    }
    
    
    private func saveCache() {
        LocalUserDefaults.shared.walletAccount = self.storedAccount
    }
    
}
//MARK: Logical processing
extension WalletAccount {
    
    mutating func readInfo(at address: String) -> WalletAccount.User {
        let currentNetwork = LocalUserDefaults.shared.flowNetwork
        if var list = self.storedAccount[key] {
            var lastUser = list.last { $0.network == currentNetwork && $0.address == address }
            if let user = lastUser{
                return user
            }else {
                let existList = list.map { $0.emoji }
                let nEmoji = generalInfo(count: 1, excluded: existList)?.first ?? .monster
                let user = WalletAccount.User(emoji: nEmoji, address: address)
                list.append(user)
                self.storedAccount[key] = list
                saveCache()
                return user
            }
        }else {
            let nEmoji = generalInfo(count: 1, excluded: [])?.first ?? .monster
            let model = WalletAccount.User(emoji: nEmoji, address: address)
            self.storedAccount[key] = [model]
            saveCache()
            return model
        }
    }
    
    mutating func update(at address: String, emoji: WalletAccount.Emoji, name: String? = nil) {
        let currentNetwork = LocalUserDefaults.shared.flowNetwork
        if var list = self.storedAccount[key] {
            if var index = list.lastIndex(where: { $0.network == currentNetwork && $0.address == address }) {
                var user = list[index]
                user.emoji = emoji
                user.name = name ?? emoji.name
                list[index] = user
                self.storedAccount[key] = list
                saveCache()
            }
        }
    }
    
    private func generalInfo(count: Int, excluded:[Emoji]) -> [WalletAccount.Emoji]? {
        let list = Emoji.allCases
        return list.randomDifferentElements(count: count,excluded: excluded)
    }
}

//MARK: data struct
extension WalletAccount {
    enum Emoji: String, CaseIterable, Codable {
        case monster = "👾"
        case devil = "👹"
        case pumpkin = "🎃"
        case joker = "🤡"
        case lion = "🦁"
        case panda = "🐼"
        case butterfly = "🦋"
        case dragon = "🐲"
        case peach = "🍑"
        case lemon = "🍋"
        case chestnut = "🌰"
        case avocado = "🥑"

        var name: String {
            switch self {
            case .monster: return "Monster"
            case .devil: return "Devil"
            case .pumpkin: return "Pumpkin"
            case .joker: return "Joker"
            case .lion: return "Lion"
            case .panda: return "Panda"
            case .butterfly: return "Butterfly"
            case .dragon: return "Dragon"
            case .peach: return "Peach"
            case .lemon: return "Lemon"
            case .chestnut: return "Chestnut"
            case .avocado: return "Avocado"
            }
        }
        
        var color: Color {
            switch self {
            case .monster:
                Color(hex: "#9170C0")
            case .devil:
                Color(hex: "#F74535")
            case .pumpkin:
                Color(hex: "#F1840B")
            case .joker:
                Color(hex: "#FAF3D2")
            case .lion:
                Color(hex: "#FFA600")
            case .panda:
                Color(hex: "#EEEEED")
            case .butterfly:
                Color(hex: "#36A5F8")
            case .dragon:
                Color(hex: "#AEE676")
            case .peach:
                Color(hex: "#FBB06B")
            case .lemon:
                Color(hex: "#FDEF85")
            case .chestnut:
                Color(hex: "#EBCA84")
            case .avocado:
                Color(hex: "#B2C45C")
            }
        }
        
        func icon(size: CGFloat = 24) -> some View {
            return VStack {
                Text(self.rawValue)
                    .font(.system(size: size/2 + 2))
            }
            .frame(width: size, height: size)
            .background(self.color)
            .cornerRadius(size/2.0)
        }
    }
    
    struct User: Codable {
        var emoji: WalletAccount.Emoji
        var name: String
        var address: String
        var network: LocalUserDefaults.FlowNetworkType
        
        init(emoji: WalletAccount.Emoji, address: String) {
            self.emoji = emoji
            self.name = emoji.name
            self.address = address
            self.network = LocalUserDefaults.shared.flowNetwork
        }
    }
}

extension Array where Element: Equatable {
    func randomDifferentElements(count: Int, excluded: [Element]) -> [Element]? {
        guard self.count >= count else {
            return nil // 确保数组中至少有指定数量的元素
        }
        
        var selectedElements: [Element] = []
        
        while selectedElements.count < count {
            let element = self.randomElement()!
            if !selectedElements.contains(element) && !excluded.contains(element) {
                selectedElements.append(element)
            }
        }
        
        return selectedElements
    }
}


