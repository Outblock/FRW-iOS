//
//  VWebLink.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 2/7/21.
//

import SwiftUI

// MARK: - VWebLink

/// Button component that controls a navigation presentation to an URL.
///
/// Component can be initialized with content or title.
///
/// Component supports presets or existing button types.
///
/// State can be passed as parameter.
///
/// Usage example:
///
///     var body: some View {
///         VWebLink(
///             preset: .secondary(),
///             url: .init(string: "https://www.apple.com"),
///             title: "Lorem ipsum"
///         )
///     }
///
public struct VWebLink<Content>: View where Content: View {
    // MARK: Lifecycle

    // MARK: Initializers - Preset

    /// Initializes component with preset, url and content.
    public init(
        preset linkPreset: VWebLinkPreset,
        state: VWebLinkState = .enabled,
        url: URL?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.linkButtonType = linkPreset.buttonType
        self.state = state
        self.url = url
        self.content = content
    }

    /// Initializes component with preset, url and title.
    public init(
        preset linkPreset: VWebLinkPreset,
        state: VWebLinkState = .enabled,
        url: URL?,
        title: String
    )
        where Content == VText {
        self.init(
            preset: linkPreset,
            state: state,
            url: url,
            content: { linkPreset.text(from: title, isEnabled: state.isEnabled) }
        )
    }

    // MARK: Initializers - Custom

    /// Initializes component with url and content.
    public init(
        state: VWebLinkState = .enabled,
        url: URL?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.linkButtonType = .custom
        self.state = state
        self.url = url
        self.content = content
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        VWebLinkType.webLinkButton(
            buttonType: linkButtonType,
            isEnabled: state.isEnabled,
            action: openURL,
            content: content
        )
    }

    // MARK: Private

    // MARK: Properties

    @Environment(\.openURL)
    private var openURLAction: OpenURLAction

    private let linkButtonType: VWebLinkType
    private let state: VWebLinkState
    private let url: URL?
    private let content: () -> Content

    // MARK: Actions

    private func openURL() {
        guard let url = url else { return }
        openURLAction(url)
    }
}

// MARK: - VWebLink_Previews

struct VWebLink_Previews: PreviewProvider {
    static var previews: some View {
        VWebLink(
            preset: .secondary(),
            url: .init(string: "https://www.apple.com"),
            title: "Lorem ipsum"
        )
    }
}
