//
//  VSegmentedPicker.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/7/21.
//

import SwiftUI

// MARK: - VSegmentedPicker

/// Item picker component that selects from a set of mutually exclusive values, and displays their representative content horizontally.
///
/// Component can be initialized with data, row titles, `VPickableItem`, or `VPickableTitledItem`.
///
/// Best suited for `2` – `3` items.
///
/// Model, state, header, footer, and disabled indexes can be passed as parameters.
///
/// Usage example:
///
///     enum PickerRow: Int, VPickableTitledItem {
///         case red, green, blue
///
///         var pickerTitle: String {
///             switch self {
///             case .red: return "Red"
///             case .green: return "Green"
///             case .blue: return "Blue"
///             }
///         }
///     }
///
///     @State var selection: PickerRow = .red
///
///     var body: some View {
///         VSegmentedPicker(
///             selection: $selection,
///             headerTitle: "Lorem ipsum dolor sit amet",
///             footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
///         )
///     }
///
public struct VSegmentedPicker<Data, RowContent>: View
    where
    Data: RandomAccessCollection,
    Data.Index == Int,
    RowContent: View {
    // MARK: Lifecycle

    // MARK: Initializers - View Builder

    /// Initializes component with selected index, header, footer, data, and row content.
    public init(
        model: VSegmentedPickerModel = .init(),
        state: VSegmentedPickerState = .enabled,
        selectedIndex: Binding<Int?>,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        disabledIndexes: Set<Int> = .init(),
        data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.model = model
        self.state = state
        _selectedIndex = selectedIndex
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.disabledIndexes = disabledIndexes
        self.data = data
        self.rowContent = rowContent
    }

    // MARK: Initializers - Row Titles

    /// Initializes component with selected index, header, footer, and row titles.
    public init(
        model: VSegmentedPickerModel = .init(),
        state: VSegmentedPickerState = .enabled,
        selectedIndex: Binding<Int?>,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        disabledIndexes: Set<Int> = .init(),
        rowTitles: [String]
    )
        where
        Data == [String],
        RowContent == VText {
        self.init(
            model: model,
            state: state,
            selectedIndex: selectedIndex,
            headerTitle: headerTitle,
            footerTitle: footerTitle,
            disabledIndexes: disabledIndexes,
            data: rowTitles,
            rowContent: { title in
                VText(
                    type: .oneLine,
                    font: model.fonts.rows,
                    color: model.colors.textContent.for(state),
                    title: title
                )
            }
        )
    }

    // MARK: Initializers - Pickable Item

    /// Initializes component with `VPickableItem`, header, footer, and row content.
    public init<Item>(
        model: VSegmentedPickerModel = .init(),
        state: VSegmentedPickerState = .enabled,
        selection: Binding<Item?>,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        disabledItems: Set<Item> = .init(),
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    )
        where
        Data == [Item],
        Item: VPickableItem {
        self.init(
            model: model,
            state: state,
            selectedIndex: .init(
                get: { selection.wrappedValue?.rawValue },
                set: { selection.wrappedValue = Item(rawValue: $0 ?? 0)! }
            ),
            headerTitle: headerTitle,
            footerTitle: footerTitle,
            disabledIndexes: .init(disabledItems.map { $0.rawValue }),
            data: .init(Item.allCases),
            rowContent: rowContent
        )
    }

    // MARK: Initializers - Pickable Titled Item

    /// Initializes component with `VPickableTitledItem`, header, and footer.
    public init<Item>(
        model: VSegmentedPickerModel = .init(),
        state: VSegmentedPickerState = .enabled,
        selection: Binding<Item>,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        disabledItems: Set<Item> = .init()
    )
        where
        Data == [Item],
        RowContent == VText,
        Item: VPickableTitledItem {
        self.init(
            model: model,
            state: state,
            selectedIndex: .init(
                get: { selection.wrappedValue.rawValue },
                set: { selection.wrappedValue = Item(rawValue: $0 ?? 0)! }
            ),
            headerTitle: headerTitle,
            footerTitle: footerTitle,
            disabledIndexes: .init(disabledItems.map { $0.rawValue }),
            data: .init(Item.allCases),
            rowContent: { item in
                VText(
                    type: .oneLine,
                    font: model.fonts.rows,
                    color: model.colors.textContent.for(state),
                    title: item.pickerTitle
                )
            }
        )
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        syncInternalStateWithState()

        return VStack(alignment: .leading, spacing: model.layout.headerFooterSpacing, content: {
            headerView
            pickerView
            footerView
        })
    }

    // MARK: Private

    // MARK: Properties

    private let model: VSegmentedPickerModel

    private let state: VSegmentedPickerState
    @State
    private var pressedIndex: Int?
    @Binding
    private var selectedIndex: Int?
    @State
    private var animatableSelectedIndex: Int?

    private let headerTitle: String?
    private let footerTitle: String?
    private let disabledIndexes: Set<Int>

    private let data: Data
    private let rowContent: (Data.Element) -> RowContent

    @State
    private var rowWidth: CGFloat = .zero

    private var pickerView: some View {
        ZStack(alignment: .leading, content: {
            background
            indicator
            rows
            dividers
        })
        .frame(height: model.layout.height)
        .cornerRadius(model.layout.cornerRadius)
    }

    @ViewBuilder
    private var headerView: some View {
        if let headerTitle = headerTitle, !headerTitle.isEmpty {
            VText(
                type: .oneLine,
                font: model.fonts.header,
                color: model.colors.header.for(state),
                title: headerTitle
            )
            .padding(.horizontal, model.layout.headerFooterMarginHorizontal)
            .opacity(model.colors.content.for(state))
        }
    }

    @ViewBuilder
    private var footerView: some View {
        if let footerTitle = footerTitle, !footerTitle.isEmpty {
            VText(
                type: .multiLine(limit: nil, alignment: .leading),
                font: model.fonts.footer,
                color: model.colors.footer.for(state),
                title: footerTitle
            )
            .padding(.horizontal, model.layout.headerFooterMarginHorizontal)
            .opacity(model.colors.content.for(state))
        }
    }

    private var background: some View {
        model.colors.background.for(state)
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: model.layout.indicatorCornerRadius)
            .padding(model.layout.indicatorMargin)
            .frame(width: rowWidth)
            .scaleEffect(indicatorScale)
            .opacity(selectedIndex == nil ? 0 : 1)
            .offset(
                x: rowWidth *
                    .init(animatableSelectedIndex ?? selectedIndex ?? (data.count / 2))
            )
            .foregroundColor(model.colors.indicator.for(state))
            .shadow(
                color: model.colors.indicatorShadow.for(state),
                radius: model.layout.indicatorShadowRadius,
                y: model.layout.indicatorShadowOffsetY
            )
    }

    private var rows: some View {
        HStack(spacing: 0, content: {
            ForEach(0..<data.count, content: { i in
                VBaseButton(
                    isEnabled: state.isEnabled && !disabledIndexes.contains(i),
                    gesture: { gestureState in
                        pressedIndex = gestureState.isPressed ? i : nil
                        if gestureState.isClicked { setSelectedIndex(to: i) }
                    },
                    content: {
                        rowContent(data[i])
                            .padding(model.layout.actualRowContentMargin)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .opacity(contentOpacity(for: i))
                            .readSize(onChange: { rowWidth = $0.width })
                    }
                )
            })
        })
    }

    private var dividers: some View {
        HStack(spacing: 0, content: {
            ForEach(0..<data.count, content: { i in
                Spacer()

                if i <= data.count - 2 {
                    Rectangle()
                        .frame(size: model.layout.dividerSize)
                        .foregroundColor(model.colors.divider.for(state))
                        .opacity(dividerOpacity(for: i))
                }
            })
        })
    }

    // MARK: State Indication

    private var indicatorScale: CGFloat {
        switch selectedIndex {
        case pressedIndex: return model.layout.indicatorPressedScale
        case _: return 1
        }
    }

    private func rowState(for index: Int) -> VSegmentedPickerRowState { .init(
        isEnabled: state.isEnabled && !disabledIndexes.contains(index),
        isPressed: pressedIndex == index
    ) }

    // MARK: State Syncs

    private func syncInternalStateWithState() {
        DispatchQueue.main.async {
            if animatableSelectedIndex == nil || animatableSelectedIndex != selectedIndex {
                withAnimation(model.animations.selection) { animatableSelectedIndex = selectedIndex
                }
            }
        }
    }

    // MARK: Actions

    private func setSelectedIndex(to index: Int) {
        withAnimation(model.animations.selection) { animatableSelectedIndex = index }
        selectedIndex = index
    }

    private func contentOpacity(for index: Int) -> Double {
        model.colors.content.for(rowState(for: index))
    }

    private func dividerOpacity(for index: Int) -> Double {
        guard let selectedIndex = selectedIndex else {
            return 1
        }
        let isBeforeIndicator: Bool = index < selectedIndex
        switch isBeforeIndicator {
        case false: return index - selectedIndex < 1 ? 0 : 1
        case true: return selectedIndex - index <= 1 ? 0 : 1
        }
    }
}

// MARK: - VSegmentedPicker_Previews

struct VSegmentedPicker_Previews: PreviewProvider {
    // MARK: Internal

    enum PickerRow: Int, VPickableTitledItem {
        case red, green, blue

        // MARK: Internal

        var pickerTitle: String {
            switch self {
            case .red: return "Red"
            case .green: return "Green"
            case .blue: return "Blue"
            }
        }
    }

    static var previews: some View {
        VSegmentedPicker(
            selection: $selection,
            headerTitle: "Lorem ipsum dolor sit amet",
            footerTitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
        )
        .padding(20)
    }

    // MARK: Private

    @State
    private static var selection: PickerRow = .red
}
