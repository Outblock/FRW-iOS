//
//  Published.swift
//  Flow Reference Wallet
//
//  Created by Selina on 9/6/2022.
//

import Combine
import Foundation

private var cancellables = [String: AnyCancellable]()

/// Use both @Published and @AppStorage
extension Published {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}
