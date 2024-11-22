//
//  VMenuSubMenu.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 2/1/21.
//

import SwiftUI

// MARK: - VMenuSubMenu

struct VMenuSubMenu: View {
    // MARK: Lifecycle

    // MARK: Initializers

    init(rows: [VMenuRow]) {
        self.rows = rows
    }

    // MARK: Internal

    // MARK: Body

    var body: some View {
        ForEach(rows.enumeratedArray().reversed(), id: \.offset, content: { _, button in
            switch button {
            case let .titled(action, title):
                Button(title, action: action)

            case let .titledSystemIcon(action, title, name):
                Button(action: action, label: {
                    Text(title)
                    Image(systemName: name)
                })

            case let .titledAssetIcon(action, title, name, bundle):
                Button(action: action, label: {
                    Text(title)
                    Image(name, bundle: bundle)
                })

            case let .menu(title, rows):
                Menu(
                    content: { VMenuSubMenu(rows: rows) },
                    label: { Text(title) }
                )
            }
        })
    }

    // MARK: Private

    // MARK: Properties

    private let rows: [VMenuRow]
}

// MARK: - VMenuSubMenu_Previews

struct VMenuSubMenu_Previews: PreviewProvider {
    static var previews: some View {
        VMenu_Previews.previews
    }
}
