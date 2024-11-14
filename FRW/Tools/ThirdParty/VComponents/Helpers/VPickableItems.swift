//
//  VPickableItems.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/8/21.
//

import SwiftUI

// MARK: - VPickableItem

/// Allows enum to represent picker items in components.
public protocol VPickableItem: RawRepresentable, CaseIterable where RawValue == Int {}

// MARK: - VPickableTitledItem

/// Allows enum to represent picker items in components.
public protocol VPickableTitledItem: VPickableItem {
    var pickerTitle: String { get }
}
