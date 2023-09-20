/**
 *  SwiftUIIndexedList
 *  Copyright (c) Ciaran O'Brien 2022
 *  MIT license, see LICENSE file for details
 */

import SwiftUI

public struct Index: Equatable {
    internal let contentID: AnyHashable
    internal let displayPriority: DisplayPriority

    private let icon: Image?
    private let title: Text?
}

public extension Index {
    enum DisplayPriority: Equatable, Hashable {
        case standard
        case increased
    }
}

public extension Index {
    init<Title, ContentID>(_ title: Title,
                           image name: String? = nil,
                           displayPriority: DisplayPriority = .standard,
                           contentID: ContentID)
        where
        Title: StringProtocol,
        ContentID: Hashable
    {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            icon = Image(name)
        } else {
            icon = nil
        }
    }

    init<ContentID>(_ title: LocalizedStringKey,
                    image name: String? = nil,
                    displayPriority: DisplayPriority = .standard,
                    contentID: ContentID)
        where ContentID: Hashable
    {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            icon = Image(name)
        } else {
            icon = nil
        }
    }

    init<Title, ContentID>(_ title: Title,
                           systemImage name: String?,
                           displayPriority: DisplayPriority = .standard,
                           contentID: ContentID)
        where
        Title: StringProtocol,
        ContentID: Hashable
    {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            icon = Image(systemName: name)
        } else {
            icon = nil
        }
    }

    init<ContentID>(_ title: LocalizedStringKey,
                    systemImage name: String?,
                    displayPriority: DisplayPriority = .standard,
                    contentID: ContentID)
        where ContentID: Hashable
    {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            icon = Image(systemName: name)
        } else {
            icon = nil
        }
    }
}

internal extension Index {
    init(separatorWith contentID: AnyHashable) {
        self.contentID = contentID
        displayPriority = .standard
        icon = nil
        title = nil
    }

    @ViewBuilder func label() -> some View {
        if let title = title {
            if let icon = icon {
                Label { title } icon: { icon }
            } else {
                title
            }
        } else {
            Circle()
                .frame(width: 6, height: 6)
        }
    }
}
