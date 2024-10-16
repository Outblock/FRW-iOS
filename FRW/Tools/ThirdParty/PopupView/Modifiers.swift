//
//  Constructors.swift
//  Pods
//
//  Created by Alisa Mylnikova on 11.10.2022.
//

import SwiftUI

public extension View {
    func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
    ) -> some View {
        modifier(
            FullscreenPopup<Int, PopupContent>(
                isPresented: isPresented,
                isBoolMode: true,
                params: customize(Popup<PopupContent>.PopupParameters()),
                view: view,
                itemView: nil
            )
        )
    }

    func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent,
        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
    ) -> some View {
        modifier(
            FullscreenPopup<Item, PopupContent>(
                item: item,
                isBoolMode: false,
                params: customize(Popup<PopupContent>.PopupParameters()),
                view: nil,
                itemView: itemView
            )
        )
    }

    func popup<PopupContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder view: @escaping () -> PopupContent
    ) -> some View {
        modifier(
            FullscreenPopup<Int, PopupContent>(
                isPresented: isPresented,
                isBoolMode: true,
                params: Popup<PopupContent>.PopupParameters(),
                view: view,
                itemView: nil
            )
        )
    }

    func popup<Item: Equatable, PopupContent: View>(
        item: Binding<Item?>,
        @ViewBuilder itemView: @escaping (Item) -> PopupContent
    ) -> some View {
        modifier(
            FullscreenPopup<Item, PopupContent>(
                item: item,
                isBoolMode: false,
                params: Popup<PopupContent>.PopupParameters(),
                view: nil,
                itemView: itemView
            )
        )
    }
}
