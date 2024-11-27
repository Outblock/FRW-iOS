//
//  _VModal.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/13/21.
//

import SwiftUI

// MARK: - _VModal

struct _VModal<Content, HeaderContent>: View
    where
    Content: View,
    HeaderContent: View
{
    // MARK: Lifecycle

    // MARK: Initializers

    init(
        model: VModalModel,
        isPresented: Binding<Bool>,
        headerContent: (() -> HeaderContent)?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.model = model
        _isHCPresented = isPresented
        self.headerContent = headerContent
        self.content = content
    }

    // MARK: Internal

    // MARK: Body

    var body: some View {
        ZStack(content: {
            blinding
            modalView
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.keyboard, edges: model.layout.ignoredKeybordSafeAreaEdges)
        .onAppear(perform: animateIn)
    }

    // MARK: Private

    // MARK: Properties

    private let model: VModalModel

    @Binding
    private var isHCPresented: Bool
    @State
    private var isViewPresented: Bool = false

    private let headerContent: (() -> HeaderContent)?
    private let content: () -> Content

    private var headerExists: Bool { headerContent != nil || model.misc.dismissType.hasButton }

    private var blinding: some View {
        model.colors.blinding
            .edgesIgnoringSafeArea(.all)
            .onTapGesture(perform: animateOutFromTap)
    }

    private var modalView: some View {
        ZStack(content: {
            VSheet(model: model.sheetSubModel)

            VStack(spacing: 0, content: {
                headerView
                dividerView
                contentView.frame(maxHeight: .infinity, alignment: .center)
            })
            .frame(maxHeight: .infinity, alignment: .top)
        })
        .frame(size: model.layout.size)
        .scaleEffect(isViewPresented ? 1 : model.animations.scaleEffect)
        .opacity(isViewPresented ? 1 : model.animations.opacity)
        .blur(radius: isViewPresented ? 0 : model.animations.blur)
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
        content()
            .padding(.leading, model.layout.contentMargins.leading)
            .padding(.trailing, model.layout.contentMargins.trailing)
            .padding(.top, model.layout.contentMargins.top)
            .padding(.bottom, model.layout.contentMargins.bottom)
    }

    private var closeButton: some View {
        VCloseButton(model: model.closeButtonSubModel, action: animateOut)
    }

    // MARK: Animations

    private func animateIn() {
        withAnimation(model.animations.appear?.asSwiftUIAnimation) { isViewPresented = true }
    }

    private func animateOut() {
        withAnimation(model.animations.disappear?.asSwiftUIAnimation) { isViewPresented = false }
        DispatchQueue.main
            .asyncAfter(deadline: .now() + (model.animations.disappear?.duration ?? 0)) {
                isHCPresented = false
            }
    }

    private func animateOutFromTap() {
        if model.misc.dismissType.contains(.backTap) { animateOut() }
    }
}

// MARK: - VModal_Previews

struct VModal_Previews: PreviewProvider {
    static var previews: some View {
        _VModal(
            model: .init(),
            isPresented: .constant(true),
            headerContent: {
                VBaseHeaderFooter(
                    frameType: .flexible(.leading),
                    font: VModalModel.Fonts().header,
                    color: VModalModel.Colors().headerText,
                    title: "Lorem ipsum dolor sit amet"
                )
            },
            content: { ColorBook.accent }
        )
    }
}
