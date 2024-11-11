//
//  FileStorage.swift
//  Flow Wallet
//
//  Created by cat on 2022/5/13.
//

import Foundation
import Haneke

// MARK: - JSONStorage

@propertyWrapper
struct JSONStorage<T: Codable> {
    // MARK: Lifecycle

    init(key: String) {
        self.key = key
        if let jsonData = UserDefaults.standard.data(forKey: theKey) {
            let decoder = JSONDecoder()
            self.value = try? decoder.decode(T.self, from: jsonData)
        }
    }

    // MARK: Internal

    var value: T?
    let key: String

    var wrappedValue: T? {
        set {
            value = newValue
            if let json = try? JSONEncoder().encode(value) {
                UserDefaults.standard.set(json, forKey: theKey)
            }
        }
        get {
            value
        }
    }

    // MARK: Private

    private var theKey: String {
        // TODO: fileName: {userId_filename}
        key
    }
}

// MARK: - JSONTestReader

@propertyWrapper
struct JSONTestReader<T: Codable> {
    // MARK: Lifecycle

    init(fileName: String) {
        self.fileName = fileName
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let url = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                self.value = try? decoder.decode(T.self, from: jsonData)
            } catch {}
        }
    }

    // MARK: Internal

    var value: T?
    let fileName: String

    var wrappedValue: T? {
        set {
            value = newValue
        }
        get {
            value
        }
    }
}
