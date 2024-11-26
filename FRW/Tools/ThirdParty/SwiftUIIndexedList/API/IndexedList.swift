/**
 *  SwiftUIIndexedList
 *  Copyright (c) Ciaran O'Brien 2022
 *  MIT license, see LICENSE file for details
 */

import SwiftUI

// MARK: - IndexedList

public struct IndexedList<SelectionValue, Indices, Content>: View
    where SelectionValue: Hashable,
    Indices: Equatable,
    Indices: RandomAccessCollection,
    Indices.Element == Index,
    Content: View {
    // MARK: Public

    public var body: some View {
        ScrollViewReader { scrollView in
            Group {
                switch selection {
                case .none: List(content: content)
                case let .single(value): List(selection: value, content: content)
                case let .multiple(value): List(selection: value, content: content)
                }
            }
            .background(UITableViewCustomizer(
                showsVerticalScrollIndicator: accessory
                    .showsScrollIndicator(indices: indices)
            ))
            .overlay(IndexBar(accessory: accessory, indices: indices, scrollView: scrollView))
            .environment(
                \.internalIndexBarInsets,
                accessory.showsIndexBar(indices: indices) ? indexBarInsets : nil
            )
        }
    }

    // MARK: Private

    private var accessory: ScrollAccessory
    private var content: () -> Content
    private var indices: Indices
    private var selection: Selection
}

extension IndexedList {
    public init(
        accessory: ScrollAccessory = .automatic,
        indices: Indices,
        selection: Binding<SelectionValue?>?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.accessory = accessory
        self.content = content
        self.indices = indices
        self.selection = .single(value: selection)
    }

    public init(
        accessory: ScrollAccessory = .automatic,
        indices: Indices,
        selection: Binding<Set<SelectionValue>>?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.accessory = accessory
        self.content = content
        self.indices = indices
        self.selection = .multiple(value: selection)
    }
}

extension IndexedList
    where Indices == [Index] {
    public init<Data, ID, ElementContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<SelectionValue?>?,
        @ViewBuilder content: @escaping (Data.Element) -> ElementContent
    )
        where
        Data: RandomAccessCollection,
        Data.Element: Indexable,
        ID: Hashable,
        ElementContent: View,
        Content == ForEach<Data, ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, id: id, content: content) }
        self.indices = data.compactMap(\.index)
        self.selection = .single(value: selection)
    }

    public init<Data, ID, ElementContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<Set<SelectionValue>>?,
        @ViewBuilder content: @escaping (Data.Element) -> ElementContent
    )
        where
        Data: RandomAccessCollection,
        Data.Element: Indexable,
        ID: Hashable,
        ElementContent: View,
        Content == ForEach<Data, ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, id: id, content: content) }
        self.indices = data.compactMap(\.index)
        self.selection = .multiple(value: selection)
    }

    public init<Data, ElementContent>(
        _ data: Data,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<SelectionValue?>?,
        @ViewBuilder content: @escaping (Data.Element) -> ElementContent
    )
        where
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Element: Indexable,
        ElementContent: View,
        Content == ForEach<Data, Data.Element.ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, content: content) }
        self.indices = data.compactMap(\.index)
        self.selection = .single(value: selection)
    }

    public init<Data, ElementContent>(
        _ data: Data,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<Set<SelectionValue>>?,
        @ViewBuilder content: @escaping (Data.Element) -> ElementContent
    )
        where
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Element: Indexable,
        ElementContent: View,
        Content == ForEach<Data, Data.Element.ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, content: content) }
        self.indices = data.compactMap(\.index)
        self.selection = .multiple(value: selection)
    }

    public init<Data, ID, ElementContent>(
        _ data: Binding<Data>,
        id: KeyPath<Data.Element, ID>,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<SelectionValue?>?,
        @ViewBuilder content: @escaping (Binding<Data.Element>)
            -> ElementContent
    )
        where
        Data: MutableCollection,
        Data: RandomAccessCollection,
        Data.Element: Indexable,
        Data.Index: Hashable,
        ID: Hashable,
        ElementContent: View,
        Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, ID)>, ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, id: id, content: content) }
        self.indices = data.wrappedValue.compactMap(\.index)
        self.selection = .single(value: selection)
    }

    public init<Data, ID, ElementContent>(
        _ data: Binding<Data>,
        id: KeyPath<Data.Element, ID>,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<Set<SelectionValue>>?,
        @ViewBuilder content: @escaping (Binding<Data.Element>)
            -> ElementContent
    )
        where
        Data: MutableCollection,
        Data: RandomAccessCollection,
        Data.Element: Indexable,
        Data.Index: Hashable,
        ID: Hashable,
        ElementContent: View,
        Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, ID)>, ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, id: id, content: content) }
        self.indices = data.wrappedValue.compactMap(\.index)
        self.selection = .multiple(value: selection)
    }

    public init<Data, ElementContent>(
        _ data: Binding<Data>,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<SelectionValue?>?,
        @ViewBuilder content: @escaping (Binding<Data.Element>)
            -> ElementContent
    )
        where
        Data: MutableCollection,
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Element: Indexable,
        Data.Index: Hashable,
        ElementContent: View,
        Content == ForEach<
            LazyMapSequence<Data.Indices, (Data.Index, Data.Element.ID)>,
            Data.Element.ID,
            ElementContent
        > {
        self.accessory = accessory
        self.content = { ForEach(data, content: content) }
        self.indices = data.wrappedValue.compactMap(\.index)
        self.selection = .single(value: selection)
    }

    public init<Data, ElementContent>(
        _ data: Binding<Data>,
        accessory: ScrollAccessory = .automatic,
        selection: Binding<Set<SelectionValue>>?,
        @ViewBuilder content: @escaping (Binding<Data.Element>)
            -> ElementContent
    )
        where
        Data: MutableCollection,
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Element: Indexable,
        Data.Index: Hashable,
        ElementContent: View,
        Content == ForEach<
            LazyMapSequence<Data.Indices, (Data.Index, Data.Element.ID)>,
            Data.Element.ID,
            ElementContent
        > {
        self.accessory = accessory
        self.content = { ForEach(data, content: content) }
        self.indices = data.wrappedValue.compactMap(\.index)
        self.selection = .multiple(value: selection)
    }
}

extension IndexedList
    where SelectionValue == Never {
    public init(
        accessory: ScrollAccessory = .automatic,
        indices: Indices,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.accessory = accessory
        self.content = content
        self.indices = indices
        self.selection = .none
    }
}

extension IndexedList
    where SelectionValue == Never,
    Indices == [Index] {
    public init<Data, ID, ElementContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        accessory: ScrollAccessory = .automatic,
        @ViewBuilder content: @escaping (Data.Element) -> ElementContent
    )
        where
        Data: RandomAccessCollection,
        Data.Element: Indexable,
        ID: Hashable,
        ElementContent: View,
        Content == ForEach<Data, ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, id: id, content: content) }
        self.indices = data.compactMap(\.index)
        self.selection = .none
    }

    public init<Data, ElementContent>(
        _ data: Data,
        accessory: ScrollAccessory = .automatic,
        @ViewBuilder content: @escaping (Data.Element) -> ElementContent
    )
        where
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Element: Indexable,
        ElementContent: View,
        Content == ForEach<Data, Data.Element.ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, content: content) }
        self.indices = data.compactMap(\.index)
        self.selection = .none
    }

    public init<Data, ID, ElementContent>(
        _ data: Binding<Data>,
        id: KeyPath<Data.Element, ID>,
        accessory: ScrollAccessory = .automatic,
        @ViewBuilder content: @escaping (Binding<Data.Element>)
            -> ElementContent
    )
        where
        Data: MutableCollection,
        Data: RandomAccessCollection,
        Data.Element: Indexable,
        Data.Index: Hashable,
        ID: Hashable,
        ElementContent: View,
        Content == ForEach<LazyMapSequence<Data.Indices, (Data.Index, ID)>, ID, ElementContent> {
        self.accessory = accessory
        self.content = { ForEach(data, id: id, content: content) }
        self.indices = data.wrappedValue.compactMap(\.index)
        self.selection = .none
    }

    public init<Data, ElementContent>(
        _ data: Binding<Data>,
        accessory: ScrollAccessory = .automatic,
        @ViewBuilder content: @escaping (Binding<Data.Element>)
            -> ElementContent
    )
        where
        Data: MutableCollection,
        Data: RandomAccessCollection,
        Data.Element: Identifiable,
        Data.Element: Indexable,
        Data.Index: Hashable,
        ElementContent: View,
        Content == ForEach<
            LazyMapSequence<Data.Indices, (Data.Index, Data.Element.ID)>,
            Data.Element.ID,
            ElementContent
        > {
        self.accessory = accessory
        self.content = { ForEach(data, content: content) }
        self.indices = data.wrappedValue.compactMap(\.index)
        self.selection = .none
    }
}

// MARK: IndexedList.Selection

extension IndexedList {
    fileprivate enum Selection {
        case none
        case single(value: Binding<SelectionValue?>?)
        case multiple(value: Binding<Set<SelectionValue>>?)
    }
}
