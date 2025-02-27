//
//  SyncStatusView.swift
//  FRW
//
//  Created by cat on 2023/12/1.
//

import Lottie
import SwiftUI

// MARK: - SyncStatusView

struct SyncStatusView: View {
    // MARK: Public

    public static let syncModel: VPrimaryButtonModel = {
        var model: VPrimaryButtonModel = .init()

        model.fonts.title = Font.LL.body.bold()
        model.colors.textContent = .init(
            enabled: Color.Theme.Text.black,
            pressed: Color.Theme.Text.black.opacity(0.5),
            loading: Color.Theme.Text.black,
            disabled: Color.Theme.Text.black
        )

        model.colors.background = .init(
            enabled: Color.Theme.Accent.green,
            pressed: Color.Theme.Accent.green.opacity(0.5),
            loading: Color.Theme.Accent.green,
            disabled: Color.Theme.Accent.green
        )
        model.layout.cornerRadius = 16
        return model
    }()

    // MARK: Internal

    @Binding
    var syncStatus: SyncAccountStatus
    @Binding
    var isPresented: Bool
    let animationView = LottieAnimationView(name: "Loading_animation", bundle: .main)

    var textColor = Color.white.opacity(0.8)

    var body: some View {
        VStack {
            Spacer()
            FlowLottieView(lottieView: animationView)
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())

            if self.syncStatus == .loading {
                loadingView
            }
            if self.syncStatus == .success {
                successView
            }
            if self.syncStatus == .syncSuccess {
                syncSuccessView
            }

            Spacer()

            VPrimaryButton(
                model: SyncStatusView.syncModel,
                action: {
                    isPresented = false
                    syncStatus = .idle
                    Router.popToRoot()
                },
                title: "start_now".localized
            )
            .padding(.bottom, 56)
            .padding(.horizontal, 18)
            .visibility(self.syncStatus != SyncAccountStatus.loading ? .visible : .invisible)
        }
        .frame(width: screenWidth, height: screenHeight)
        .ignoresSafeArea()
        .onAppear {
            animationView.backgroundBehavior = .pauseAndRestore
            animationView.play(toProgress: .infinity, loopMode: .loop)
        }
    }

    var loadingView: some View {
        VStack {
            Text("Loading")
                .font(.inter(size: 16, weight: .semibold))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)

            Text("It might take a while, please do not exit...")
                .font(.inter(size: 12))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
        }
    }

    var successView: some View {
        VStack {
            Text("Congratulations!")
                .font(.Ukraine(size: 30, weight: .bold))
                .foregroundStyle(Color.Theme.Accent.green)
                .multilineTextAlignment(.center)

            Text("Import Successful 🎉")
                .font(.inter(size: 20, weight: .bold))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
        }
    }

    var syncSuccessView: some View {
        VStack {
            Text("Congratulations!")
                .font(.Ukraine(size: 30, weight: .bold))
                .foregroundStyle(Color.Theme.Accent.green)
                .multilineTextAlignment(.center)

            Text("Sync Successful 🎉")
                .font(.inter(size: 20, weight: .bold))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    SyncStatusView(syncStatus: .constant(SyncAccountStatus.loading), isPresented: .constant(true))
}

// MARK: - FlowLottieView

struct FlowLottieView: UIViewRepresentable {
    var lottieView: LottieAnimationView

    func makeUIView(context _: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        addLottieView(to: view)
        return view
    }

    func updateUIView(_: UIView, context _: Context) {}

    func addLottieView(to: UIView) {
        // MARK: Memory Properties

        lottieView.backgroundBehavior = .pauseAndRestore
        lottieView.shouldRasterizeWhenIdle = true

        lottieView.backgroundColor = .clear
        lottieView.contentMode = .scaleAspectFit
        lottieView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            lottieView.widthAnchor.constraint(equalTo: to.widthAnchor),
            lottieView.heightAnchor.constraint(equalTo: to.heightAnchor),
        ]

        to.addSubview(lottieView)
        to.addConstraints(constraints)
    }
}
