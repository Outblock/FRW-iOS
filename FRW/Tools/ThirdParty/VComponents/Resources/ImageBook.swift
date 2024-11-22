//
//  ImageBook.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/18/21.
//

import SwiftUI

// MARK: - ImageBook

struct ImageBook {
    // MARK: Lifecycle

    // MARK: Initializers

    private init() {}

    // MARK: Internal

    // MARK: Properties

    static var checkBoxOn: Image { .init(componentAsset: "CheckBox.On") }
    static var checkBoxInterm: Image { .init(componentAsset: "CheckBox.Interm") }

    static var chevronUp: Image { .init(componentAsset: "Chevron.Up") }

    static var minus: Image { .init(componentAsset: "Minus") }
    static var plus: Image { .init(componentAsset: "Plus") }

    static var search: Image { .init(componentAsset: "Search") }

    static var visibilityOff: Image { .init(componentAsset: "Visibility.off") }
    static var visibilityOn: Image { .init(componentAsset: "Visibility.on") }

    static var xMark: Image { .init(componentAsset: "XMark") }

    static var googleDrive: Image { .init(componentAsset: "Google.Drive") }
    static var icloud: Image { .init(componentAsset: "Icloud") }

    static var flow: Image { .init(componentAsset: "Flow") }
}

// MARK: - Helpers

extension Image {
    /// Initializes color from library's local assets library from a name.
    init(componentAsset name: String) {
        self = Image(name, bundle: Bundle.main)
            .renderingMode(.template)
    }
}
