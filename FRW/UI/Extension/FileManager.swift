//
//  FileManager.swift
//  Flow Wallet
//
//  Created by Selina on 9/10/2022.
//

import Foundation

extension FileManager {
    @discardableResult
    public func createFolder(_ url: URL) -> Bool {
        do {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
}
