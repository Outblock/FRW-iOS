//
//  SyncConfirmView.swift
//  FRW
//
//  Created by cat on 2023/11/28.
//

import Kingfisher
import SwiftUI
import SwiftUIX

struct SyncConfirmView: RouteableView {
    @StateObject var viewModel: SyncConfirmViewModel

    var user: SyncInfo.User

    var title: String {
        ""
    }

    init(user: SyncInfo.User) {
        self.user = user
        _viewModel = StateObject(wrappedValue: SyncConfirmViewModel(userId: user.userId ?? ""))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("confirm_tag".localized)
                    .font(.inter(size: 30, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
                HStack {
                    Text("importing_tag".localized)
                        .font(.inter(size: 30, weight: .bold))
                        .foregroundStyle(Color.Theme.Text.black8)
                    Text("wallet".localized)
                        .font(.inter(size: 30, weight: .bold))
                        .foregroundStyle(Color.Theme.Accent.green)
                }
            }

            Text("find_matching_wallet".localized)
                .font(.inter(size: 16, weight: .semibold))
                .foregroundStyle(Color.Theme.Accent.grey)
                .padding(.top, 14)

            Color.clear
                .frame(height: 50)

            Button {} label: {
                userInfoView
            }

            Spacer()

            VPrimaryButton(model: ButtonStyle.primary,
                           action: {
                               onConfirm()
                           }, title: "confirm_tag".localized)
        }
        .padding(.horizontal, 24)
        .applyRouteable(self)
        .fullScreenCover(isPresented: $viewModel.isPresented) {
            SyncStatusView(syncStatus: $viewModel.status, isPresented: $viewModel.isPresented)
                .background(ClearBackgroundView())
        }
    }

    var userInfoView: some View {
        HStack(spacing: 12) {
            KFImage.url(URL(string: (user.userAvatar ?? "").convertedAvatarString()))
                .placeholder {
                    Image("placeholder")
                        .resizable()
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .cornerRadius(18)

            Text("@\(user.userName ?? "")")
                .font(.inter(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "#333333"))

            Text("\(user.walletAddress ?? "")")
                .font(.inter(size: 12, weight: .regular))
                .foregroundColor(Color(hex: "#808080"))

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.05))
        .contentShape(Rectangle())
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), x: 0, y: 4, blur: 16)
    }

    func onConfirm() {
        viewModel.onAddDevice()
    }
}

#Preview {
    SyncConfirmView(user: SyncInfo.User(userAvatar: "", userName: "six", walletAddress: "0x1231231", userId: "123123"))
}

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context _: Context) -> UIView {
        return InnerView()
    }

    func updateUIView(_: UIView, context _: Context) {}

    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()

            superview?.superview?.backgroundColor = UIColor.black.alpha(0.8)
        }
    }
}
