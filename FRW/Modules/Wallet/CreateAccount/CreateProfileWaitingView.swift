//
//  CreateProfileWaitingView.swift
//  FRW
//
//  Created by cat on 2024/6/5.
//

import SwiftUI
import SwiftUIPager
import SwiftUIX

// MARK: - CreateProfileWaitingView

struct CreateProfileWaitingView: RouteableView {
    // MARK: Lifecycle

    init(_ viewModel: CreateProfileWaitingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Internal

    @StateObject
    var viewModel: CreateProfileWaitingViewModel

    var title: String {
        ""
    }

    var isNavigationBarHidden: Bool {
        true
    }

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image("lilico-app-icon")
                    .resizable()
                    .frame(width: 32, height: 32)
                Text("app_name_full".localized)
                    .font(.inter(size: 18, weight: .semibold))
                    .foregroundStyle(Color.Theme.Text.black)
                Spacer()
            }
            .padding(.leading, 32)

            Spacer()
            if viewModel.createFinished {
                SuccessView()
            } else {
                bodyContainer
                    .padding(.bottom, 12)
                HStack {
                    Spacer()
                    HStack(spacing: 15) {
                        ForEach(items.indices, id: \.self) { index in
                            let item = items[viewModel.currentPage]
                            Capsule()
                                .fill(
                                    viewModel.currentPage == index ? item.color : Color.Theme.Line
                                        .line
                                )
                                .frame(width: viewModel.currentPage == index ? 20 : 7, height: 7)
                        }
                    }
                    .overlay(alignment: .leading) {
                        let item = items[viewModel.currentPage]
                        Capsule()
                            .fill(item.color)
                            .frame(width: 20, height: 7)
                            .offset(x: getOffset())
                    }
                    Color.clear
                        .frame(width: 48, height: 1)
                }
                .padding(.bottom, 32)
            }

            HStack(alignment: .center) {
                Spacer()
                if viewModel.createFinished {
                    VStack(spacing: 0) {
                        Button {
                            viewModel.onCreateBackup()
                        } label: {
                            HStack {
                                Text("create_backup".localized)
                                    .font(.inter(size: 14, weight: .bold))
                                    .foregroundStyle(Color.Theme.Text.white9)
                            }
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.Theme.Accent.green)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    VStack {
                        HStack {
                            Text("😃")
                                .font(.inter(size: 14, weight: .bold))
                            Text("take_mins".localized)
                                .font(.inter(size: 14))
                                .foregroundStyle(Color.Theme.Accent.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.Theme.Accent.green.opacity(0.12))
                        .cornerRadius(8)

                        HStack {
                            Text("create_profile::creating".localized)
                                .font(.inter(size: 14, weight: .bold))
                                .foregroundStyle(Color.Theme.Accent.green)
                            ActivityIndicator()
                        }
                        .frame(width: 220, height: 56)
                        .border(Color.Theme.Accent.green, cornerRadius: 16)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 30)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color.Theme.Background.grey)
        .applyRouteable(self)
    }

    var items: [CreateProfileWaitingView.Item] {
        CreateProfileWaitingView.Item.default()
    }

    var spinnerSubModel: VSpinnerModelContinous {
        var model: VSpinnerModelContinous = .init()
        model.colors.spinner = Color.Theme.Accent.green
        return model
    }

    func getOffset() -> CGFloat {
        CGFloat(22 * viewModel.currentPage)
    }
}

extension CreateProfileWaitingView {
    var bodyContainer: some View {
        Pager(
            page: viewModel.page,
            data: CreateProfileWaitingView.Item.default(),
            id: \.self
        ) { item in
            createPageView(item: item)
        }
        .bounces(false)
        .onDraggingBegan {
            viewModel.onPageDrag(true)
        }
        .onDraggingEnded {
            viewModel.onPageDrag(false)
        }
        .onPageWillChange { willIndex in
            viewModel.onPageIndexChangeAction(willIndex)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func createPageView(item: CreateProfileWaitingView.Item) -> some View {
        VStack(alignment: .leading) {
            Spacer()
            VStack(alignment: .leading, spacing: 25) {
                HStack(alignment: .top) {
                    VStack {
                        Text(item.title)
                            .font(.Ukraine(size: 48, weight: .light))
                            .foregroundStyle(Color.Theme.Text.black)
                            .padding(.trailing, 32)

                        Spacer()
                    }
                    Spacer()
                }
                .frame(height: 318)
                .background {
                    VStack {
                        HStack {
                            Spacer()
                            Image(item.image)
                                .offset(y: 10)
                        }
                    }
                }

                Text(item.desc)
                    .font(.inter(size: 18, weight: .light))
                    .foregroundStyle(Color.Theme.Text.black8)
                    .padding(.trailing, 32)
            }

            Spacer()
        }
        .padding(.leading, 32)
    }
}

// MARK: CreateProfileWaitingView.SuccessView

extension CreateProfileWaitingView {
    struct SuccessView: View {
        let item = CreateProfileWaitingView.Item.finishedItem

        var body: some View {
            VStack(alignment: .leading) {
                Spacer()
                VStack(alignment: .leading, spacing: 25) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 32) {
                            Text(item.title)
                                .font(.Ukraine(size: 48, weight: .light))
                                .foregroundStyle(Color.Theme.Text.black)
//                                .padding(.leading, 32)
                            Text("#onFlow.")
                                .font(.Ukraine(size: 48, weight: .thin))
                                .fontWeight(.thin)
                                .foregroundStyle(Color.Theme.Text.white9)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 4)
                                .background(Color.Theme.Accent.green)
                                .cornerRadius(29)

                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(height: 327)
                    .background {
                        VStack {
                            HStack {
                                Spacer()
                                Image(item.image)
                                    .offset(y: 30)
                            }
                        }
                    }

                    Text(item.desc)
                        .font(.inter(size: 18, weight: .light))
                        .foregroundStyle(Color.Theme.Text.black8)
                        .padding(.trailing, 32)
                }

                Spacer()
            }
            .padding(.leading, 32)
        }
    }
}

// MARK: CreateProfileWaitingView.Item

extension CreateProfileWaitingView {
    struct Item: Equatable, Hashable {
        static var finishedItem = Item(
            title: "create_profile::waiting::finished:title".localized,
            desc: "create_profile::waiting::finished:description".localized,
            image: "create_profile_bg",
            color: .Theme.Background.pureWhite
        )

        let title: String
        let desc: String
        let image: String
        let color: Color

        static func `default`() -> [CreateProfileWaitingView.Item] {
            [
                Item(
                    title: "create_profile::waiting::carousel::1::title".localized,
                    desc: "create_profile::waiting::carousel::1::description".localized,
                    image: "create_profile_bg_0",
                    color: Color.Theme.Accent.green
                ),
                Item(
                    title: "create_profile::waiting::carousel::2::title".localized,
                    desc: "create_profile::waiting::carousel::2::description".localized,
                    image: "create_profile_bg_1",
                    color: Color.Theme.Accent.purple
                ),
                Item(
                    title: "create_profile::waiting::carousel::3::title".localized,
                    desc: "create_profile::waiting::carousel::3::description".localized,
                    image: "create_profile_bg_2",
                    color: Color.Theme.Accent.blue
                )
            ]
        }
    }
}

#Preview("default") {
    CreateProfileWaitingView(CreateProfileWaitingViewModel(txId: "", callback: { _, _ in

    }))
}

#Preview("finished dark") {
    let viewModel: CreateProfileWaitingViewModel =  {
        let vm = CreateProfileWaitingViewModel(txId: "", callback: { _, _ in })
        vm.createFinished = true
        return vm
    }()
    CreateProfileWaitingView(viewModel)
        .preferredColorScheme(.dark)
}

#Preview("finished light") {
    let viewModel: CreateProfileWaitingViewModel =  {
        let vm = CreateProfileWaitingViewModel(txId: "", callback: { _, _ in })
        vm.createFinished = true
        return vm
    }()
    CreateProfileWaitingView(viewModel)
        .preferredColorScheme(.light)
}
