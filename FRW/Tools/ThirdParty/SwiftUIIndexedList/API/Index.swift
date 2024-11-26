/**
 *  SwiftUIIndexedList
 *  Copyright (c) Ciaran O'Brien 2022
 *  MIT license, see LICENSE file for details
 */

import SwiftUI

// MARK: - Index

public struct Index: Equatable {
    // MARK: Internal

    let contentID: AnyHashable
    let displayPriority: DisplayPriority

    // MARK: Private

    private let icon: Image?
    private let title: Text?
}

// MARK: Index.DisplayPriority

extension Index {
    public enum DisplayPriority: Equatable, Hashable {
        case standard
        case increased
    }
}

extension Index {
    public init<Title, ContentID>(
        _ title: Title,
        image name: String? = nil,
        displayPriority: DisplayPriority = .standard,
        contentID: ContentID
    )
        where
        Title: StringProtocol,
        ContentID: Hashable {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            self.icon = Image(name)
        } else {
            self.icon = nil
        }
    }

    public init<ContentID>(
        _ title: LocalizedStringKey,
        image name: String? = nil,
        displayPriority: DisplayPriority = .standard,
        contentID: ContentID
    )
        where ContentID: Hashable {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            self.icon = Image(name)
        } else {
            self.icon = nil
        }
    }

    public init<Title, ContentID>(
        _ title: Title,
        systemImage name: String?,
        displayPriority: DisplayPriority = .standard,
        contentID: ContentID
    )
        where
        Title: StringProtocol,
        ContentID: Hashable {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            self.icon = Image(systemName: name)
        } else {
            self.icon = nil
        }
    }

    public init<ContentID>(
        _ title: LocalizedStringKey,
        systemImage name: String?,
        displayPriority: DisplayPriority = .standard,
        contentID: ContentID
    )
        where ContentID: Hashable {
        self.contentID = AnyHashable(contentID)
        self.displayPriority = displayPriority
        self.title = Text(title)

        if let name = name {
            self.icon = Image(systemName: name)
        } else {
            self.icon = nil
        }
    }
}

extension Index {
    init(separatorWith contentID: AnyHashable) {
        self.contentID = contentID
        self.displayPriority = .standard
        self.icon = nil
        self.title = nil
    }

    @ViewBuilder
    func label() -> some View {
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
