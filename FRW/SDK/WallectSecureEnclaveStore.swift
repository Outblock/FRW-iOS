//
//  WallectSecureEnclaveStore.swift
//  FRW
//
//  Created by cat on 2023/11/7.
//

import Foundation
import KeychainAccess

public extension WallectSecureEnclave {
    enum StoreError: Error {
        case unowned
        case encode
        case decode
    }

    enum Store {
        private static var service: String = "io.outblock.lilico.securekey"
        private static var userKey: String = "user"

        public static func store(user: StoreUser) throws {
            let list = try? loginedUser()
            var userList: [StoreUser] = []
            userList.append(user)
            userList.append(contentsOf: list ?? [])
            guard let data = try? JSONEncoder().encode(userList) else {
                print("[SecureEnclave] store failed ")
                throw StoreError.encode
            }
            let keychain = Keychain(service: service)
            keychain[data: userKey] = data
        }

        public static func loginedUser() throws -> [StoreUser] {
            let keychain = Keychain(service: service)
            guard let data = try? keychain.getData(userKey) else {
                print("[SecureEnclave] get value from keychain empty ")
                return []
            }
            guard let users = try? JSONDecoder().decode([StoreUser].self, from: data) else {
                print("[SecureEnclave] decoder failed on loginedUser ")
                throw StoreError.encode
            }
            return users
        }
    }

    struct StoreUser: Codable {
        let uid: String
        var avatar: String?
        var username: String?
        var address: String?
        var publicKeyData: Data?
    }
}
