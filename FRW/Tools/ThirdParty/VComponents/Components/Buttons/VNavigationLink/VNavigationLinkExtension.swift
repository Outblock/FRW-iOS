//
//  VNavigationLinkExtension.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 8/26/21.
//

import SwiftUI

// MARK: - Extension

extension View {
    /// Allows for navigation without an explicit `VNavigationLink`.
    ///
    /// Usage example:
    ///
    ///     @State var isActive: Bool = false
    ///
    ///     var body: some View {
    ///         VNavigationView(content: {
    ///             VBaseView(title: "Home", content: {
    ///                 ZStack(content: {
    ///                     ColorBook.canvas.edgesIgnoringSafeArea(.all)
    ///
    ///                     VSheet()
    ///
    ///                     VPlainButton(
    ///                         action: { isActive = true },
    ///                         title: "Lorem ipsum"
    ///                     )
    ///                 })
    ///                     .vNavigationLink(isActive: $isActive, destination: destination)
    ///             })
    ///         })
    ///     }
    ///
    ///     var destination: some View {
    ///         VBaseView(title: "Destination", content: {
    ///             ZStack(content: {
    ///                 ColorBook.canvas.edgesIgnoringSafeArea(.all)
    ///
    ///                 VSheet()
    ///             })
    ///         })
    ///     }
    ///
    @ViewBuilder
    public func vNavigationLink<Destination>(
        isActive: Binding<Bool>,
        destination: Destination
    ) -> some View
        where Destination: View {
        background(
            VNavigationLink(
                isActive: isActive,
                destination: destination,
                content: { EmptyView() }
            )
            .allowsHitTesting(false)
            .opacity(0)
        )
    }
}
