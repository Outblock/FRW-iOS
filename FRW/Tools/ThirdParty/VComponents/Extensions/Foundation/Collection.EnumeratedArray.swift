//
//  Collection.EnumeratedArray.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/10/21.
//

import Foundation

// MARK: - Enumerated Array

extension Collection {
    func enumeratedArray() -> [(offset: Int, element: Self.Element)] {
        .init(enumerated())
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index?) -> Element? {
        guard let correctIndex = index else {
            return nil
        }
        return indices.contains(correctIndex) ? self[correctIndex] : nil
    }
}
