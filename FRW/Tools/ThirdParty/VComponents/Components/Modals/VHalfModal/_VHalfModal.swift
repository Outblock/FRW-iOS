//
//  _VHalfModal.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/21/21.
//

import SwiftUI

// MARK: - _VHalfModal

struct _VHalfModal<Content, HeaderContent>: View
    where
    Content: View,
    HeaderContent: View {
    // MARK: Lifecycle

    // MARK: Initializers

    init(
        model: VHalfModalModel,
        isPresented: Binding<Bool>,
        headerContent: (() -> HeaderContent)?,
        content: @escaping () -> Content
    ) {
        self.model = model
        _isHCPresented = isPresented
        self.headerContent = headerContent
        self.content = content

        self.isLayoutValid =
            model.layout.height.min <= model.layout.height.ideal &&
            model.layout.height.ideal <= model.layout.height.max
    }

    // MARK: Internal

    // MARK: Body

    var body: some View {
        syncInternalStateWithState()

        return ZStack(alignment: .bottom, content: {
            blinding
            modalView
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard, edges: model.layout.ignoredKeybordSafeAreaEdges)
        .onAppear(perform: animateIn)
    }

    // MARK: Private

    // MARK: Region

    private enum Region {
        // MARK: Cases

        case idealMax, ideal, minIdeal

        // MARK: Lifecycle

        // MARK: Initializrs

        init(offset: CGFloat, min _: CGFloat, ideal: CGFloat, max: CGFloat) {
            // max means offset of max, not maximum allowed offset. Otherwise, the logic would seem nverted
            switch offset {
            case ideal: self = .ideal
            case max..<ideal: self = .idealMax
            default: self =
                .minIdeal // Min isn't used to allow registering area between dismiss point and min
            }
        }
    }

    // MARK: Properties

    private let model: VHalfModalModel

    @Binding
    private var isHCPresented: Bool
    @State
    private var isViewPresented: Bool = false

    private let headerContent: (() -> HeaderContent)?
    private let content: () -> Content

    @State
    private var offset: CGFloat?
    @State
    private var offsetBeforeDrag: CGFloat?

    private let isLayoutValid: Bool

    private var headerExists: Bool { headerContent != nil || model.misc.dismissType.hasButton }
    private var hasGrabber: Bool {
        model.layout.hasGrabber &&
            (model.misc.dismissType.contains(.pullDown) || model.layout.height.isResizable)
    }

    private var blinding: some View {
        model.colors.blinding
            .edgesIgnoringSafeArea(.all)
            .onTapGesture(perform: animateOutFromBackTap)
    }

    @ViewBuilder
    private var modalView: some View {
        if isLayoutValid {
            ZStack(alignment: .top, content: {
                VSheet(model: model.sheetModel)
                    .edgesIgnoringSafeArea(.all)
                    .frame(
                        height: model.layout.height.max - UIView
                            .bottomSafeAreaHeight
                    ) // NOTE: Duplicated on all views in ZStack due to DragGesture
                    .offset(
                        y: isViewPresented ? (offset ?? .zero) : model.layout.height
                            .max
                    ) // NOTE: Duplicated on all views in ZStack due to DragGesture
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged(dragChanged)
                            .onEnded(dragEnded)
                    )

                VStack(spacing: 0, content: {
                    grabberView
                    headerView
                    dividerView
                    contentView.frame(maxHeight: .infinity, alignment: .center)
                })
                .edgesIgnoringSafeArea(model.layout.edgesToIgnore)
                .frame(maxHeight: .infinity, alignment: .top)
                .frame(
                    height: model.layout.height.max - UIView
                        .bottomSafeAreaHeight
                ) // NOTE: Duplicated on all views in ZStack due to DragGesture
                .offset(
                    y: isViewPresented ? (offset ?? .zero) : model.layout.height
                        .max
                ) // NOTE: Duplicated on all views in ZStack due to DragGesture

                navigationBarCloseButton
                    .edgesIgnoringSafeArea(.all)
                    .frame(
                        height: model.layout.height.max - UIView
                            .bottomSafeAreaHeight
                    ) // NOTE: Duplicated on all views in ZStack due to DragGesture
                    .offset(
                        y: isViewPresented ? (offset ?? .zero) : model.layout.height
                            .max
                    ) // NOTE: Duplicated on all views in ZStack due to DragGesture
            })
        }
    }

    @ViewBuilder
    private var grabberView: some View {
        if hasGrabber {
            RoundedRectangle(cornerRadius: model.layout.grabberCornerRadius)
                .frame(size: model.layout.grabberSize)
                .padding(.top, model.layout.grabberMargins.top)
                .padding(.bottom, model.layout.grabberMargins.bottom)
                .foregroundColor(model.colors.grabber)
        }
    }

    @ViewBuilder
    private var headerView: some View {
        if headerExists {
            HStack(spacing: model.layout.headerSpacing, content: {
                if model.misc.dismissType.contains(.leadingButton) {
                    closeButton
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let headerContent = headerContent {
                    headerContent()
                        .layoutPriority(1) // Overrides close button's maxWidth: .infinity. Also, header content is by default maxWidth and leading justified.
                }

                if model.misc.dismissType.contains(.trailingButton) {
                    closeButton
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            })
            .padding(.leading, model.layout.headerMargins.leading)
            .padding(.trailing, model.layout.headerMargins.trailing)
            .padding(.top, model.layout.headerMargins.top)
            .padding(.bottom, model.layout.headerMargins.bottom)
        }
    }

    @ViewBuilder
    private var dividerView: some View {
        if headerExists && model.layout.hasDivider {
            Rectangle()
                .frame(height: model.layout.headerDividerHeight)
                .padding(.leading, model.layout.headerDividerMargins.leading)
                .padding(.trailing, model.layout.headerDividerMargins.trailing)
                .padding(.top, model.layout.headerDividerMargins.top)
                .padding(.bottom, model.layout.headerDividerMargins.bottom)
                .foregroundColor(model.colors.headerDivider)
        }
    }

    private var contentView: some View {
        ZStack(content: {
            Color.clear // Overrides drag on edge of sheet
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 0))

            content()
                .padding(.leading, model.layout.contentMargins.leading)
                .padding(.trailing, model.layout.contentMargins.trailing)
                .padding(.top, model.layout.contentMargins.top)
                .padding(.bottom, model.layout.contentMargins.bottom)
        })
    }

    private var closeButton: some View {
        VCloseButton(model: model.closeButtonSubModel, action: animateOut)
    }

    @ViewBuilder
    private var navigationBarCloseButton: some View {
        if model.misc.dismissType.contains(.navigationViewCloseButton) {
            VCloseButton(model: model.closeButtonSubModel, action: animateOut)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing, VHalfModalModel.Layout.navBarCloseButtonMarginTrailing)
                .padding(.top, VHalfModalModel.Layout.navBarCloseButtonMarginTop)
        }
    }

    // MARK: State Syncs

    private func syncInternalStateWithState() {
        DispatchQueue.main.async {
            resetOffsetIsNil()
        }
    }

    private func resetOffsetIsNil() {
        if offset == nil { offset = model.layout.height.max - model.layout.height.ideal }
    }

    // MARK: Animation

    private func animateIn() {
        resetOffsetIsNil()
        withAnimation(model.animations.appear?.asSwiftUIAnimation) { isViewPresented = true }
    }

    private func animateOut() {
        withAnimation(model.animations.disappear?.asSwiftUIAnimation) { isViewPresented = false }
        DispatchQueue.main
            .asyncAfter(deadline: .now() + (model.animations.disappear?.duration ?? 0)) {
                isHCPresented = false
            }
    }

    private func animateOutFromDrag() {
        withAnimation(VHalfModalModel.Animations.dragDisappear.asSwiftUIAnimation) {
            isViewPresented = false
        }
        DispatchQueue.main
            .asyncAfter(deadline: .now() + VHalfModalModel.Animations.dragDisappear.duration) {
                isHCPresented = false
            }
    }

    private func animateOutFromBackTap() {
        if model.misc.dismissType.contains(.backTap) { animateOut() }
    }

    // MARK: Gestures

    private func dragChanged(drag: DragGesture.Value) {
        if offsetBeforeDrag == nil { offsetBeforeDrag = offset }

        let rawOffset: CGFloat = offsetBeforeDrag! + drag.translation.height
        let maxAllowedOffset: CGFloat = model.layout.height.max - model.layout.height.min
        let minAllowedOffset: CGFloat = model.layout.height.max - model.layout.height.max

        offset = {
            switch rawOffset {
            case ...minAllowedOffset: return minAllowedOffset
            case maxAllowedOffset...: return model.misc.dismissType
                .contains(.pullDown) ? rawOffset : minAllowedOffset
            default: return rawOffset
            }
        }()
    }

    private func dragEnded(drag: DragGesture.Value) {
        defer { offsetBeforeDrag = nil }
        guard let offsetBeforeDrag = offsetBeforeDrag
        else { return } // Content may cause gesture to skip onChange

        let shouldDismiss: Bool = {
            let rawOffset: CGFloat = offsetBeforeDrag + drag.translation.height
            let maxAllowedOffset: CGFloat = model.layout.height.max - model.layout.height.min

            guard model.misc.dismissType.contains(.pullDown) else { return false }

            let isDraggedDown: Bool = drag.translation.height > 0
            guard isDraggedDown else { return false }

            guard rawOffset - maxAllowedOffset >=
                abs(model.layout.translationBelowMinHeightToDismiss) else { return false }

            return true
        }()

        switch shouldDismiss {
        case false:
            let newOffsetOpt: CGFloat? = {
                guard let offset = offset else { return nil }

                let minOffset: CGFloat = model.layout.height.max - model.layout.height.min
                let idealOffset: CGFloat = model.layout.height.max - model.layout.height.ideal
                let maxOffset: CGFloat = model.layout.height.max - model.layout.height.max

                switch Region(offset: offset, min: minOffset, ideal: idealOffset, max: maxOffset) {
                case .idealMax:
                    let idealDiff: CGFloat = abs(idealOffset - offset)
                    let maxDiff: CGFloat = abs(maxOffset - offset)
                    let newOffset: CGFloat = idealDiff < maxDiff ? idealOffset : maxOffset
                    return newOffset

                case .ideal:
                    return nil

                case .minIdeal:
                    let minDiff: CGFloat = abs(minOffset - offset)
                    let idealDiff: CGFloat = abs(idealOffset - offset)
                    let newOffset: CGFloat = minDiff < idealDiff ? minOffset : idealOffset
                    return newOffset
                }
            }()

            guard let newOffset: CGFloat = newOffsetOpt else { return }

            withAnimation(model.animations.heightSnap) { offset = newOffset }

        case true:
            animateOutFromDrag()
        }
    }
}

// MARK: - VHalfModal_Previews

struct VHalfModal_Previews: PreviewProvider {
    static var previews: some View {
        _VHalfModal(
            model: .init(),
            isPresented: .constant(true),
            headerContent: {
                VBaseHeaderFooter(
                    frameType: .flexible(.leading),
                    font: VHalfModalModel.Fonts().header,
                    color: VHalfModalModel.Colors().headerText,
                    title: "Lorem ipsum dolor sit amet"
                )
            },
            content: { ColorBook.accent }
        )
    }
}
