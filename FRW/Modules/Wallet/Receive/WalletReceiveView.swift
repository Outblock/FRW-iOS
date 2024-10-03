//
//  WalletReceiveView.swift
//  Flow Wallet
//
//  Created by Selina on 6/7/2022.
//

import LinkPresentation
import QRCode
import SwiftUI

struct WalletReceiveView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WalletReceiveView()
        }
    }
}

struct WalletReceiveView: RouteableView {
    @StateObject var vm = WalletReceiveViewModel()

    var title: String {
        return ""
    }

    func backButtonAction() {
        Router.dismiss()
    }

    @State var isDismissing: Bool = false
    @State var dragOffset: CGSize = .zero
    @State var dragOffsetPredicted: CGSize = .zero

    @State var isShowing: Bool = false

    var body: some View {
        VStack(alignment: .center) {
            //            addressView
            Spacer()

            if isShowing {
                VStack(alignment: .center, spacing: 15) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.LL.Neutrals.neutrals8)

                    qrCodeContainerView

                    copyButton

                    shareButton
                }
                .transition(.offset(CGSize(width: 0, height: UIScreen.screenHeight / 2)))
            }

            Spacer()
        }
        .animation(.alertViewSpring, value: isShowing)
        .offset(x: 0, y: self.dragOffset.height > 0 ? self.dragOffset.height : 0)
        .gesture(DragGesture()
            .onChanged { value in
                self.dragOffset = value.translation
                self.dragOffsetPredicted = value.predictedEndTranslation
            }
            .onEnded { _ in
                if (self.dragOffset.height > 100) || (self.dragOffsetPredicted.height / (self.dragOffset.height)) > 2 {
                    withAnimation(.spring()) {
                        //                        self.dragOffset = self.dragOffsetPredicted
                        self.dragOffset = CGSize(width: 0, height: UIScreen.screenHeight / 2)
                    }

                    self.isDismissing = true
                    self.isShowing = false

                    // Hacky way
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        Router.dismiss(animated: false)
                    }

                    return
                } else {
                    withAnimation(.interactiveSpring()) {
                        self.dragOffset = .zero
                    }
                }
            }
        )
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(
            Color(hex: "#333333")
                .opacity(isShowing ? (1.0 - (Double(max(0, self.dragOffset.height)) / 1000)) : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.alertViewSpring, value: isShowing)
        )
        .edgesIgnoringSafeArea(.all)
        .applyRouteable(self)
        .onAppear {
            isShowing = true
            dragOffset = .zero
            dragOffsetPredicted = .zero
        }
    }

    var addressView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("wallet_address".localized)
                    .foregroundColor(.white)
                    .font(.inter(size: 14, weight: .semibold))
                Text("(\(vm.address))")
                    .foregroundColor(.white)
                    .font(.inter(size: 14, weight: .medium))
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.LL.Primary.salmonPrimary.cornerRadius(16))
        .padding(.horizontal, 18)
        .zIndex(1)
    }

    var qrCodeContainerView: some View {
        VStack(spacing: 0) {
            ZStack {
                qrCodeView
//                Image("lilico-app-icon")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 60)
//                    .padding(5)
//                    .background(
//                        Color.LL.Neutrals.background
                ////                        .thickMaterial
                ////                            .opacity(0.95)
                ////                            .blur(radius: 2)
//                    )
//                    .colorScheme(.light)
//                    .cornerRadius(30)
            }
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(currentNetwork.isMainnet ? Color.LL.Neutrals.background : currentNetwork.color, lineWidth: 5)
                    .colorScheme(.light)
            )
            .aspectRatio(1, contentMode: .fit)
        }
        .frame(width: min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.75)
        .aspectRatio(1, contentMode: .fill)
    }

    var copyButton: some View {
        Button {
            vm.copyAddressAction()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } label: {
            VStack(spacing: 12) {
                HStack {
                    Text("Flow Address".localized)
                        .font(.LL.mindTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.LL.Neutrals.background)
                        .colorScheme(.light)

                    if !currentNetwork.isMainnet {
                        Text(currentNetwork.rawValue)
                            .textCase(.uppercase)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 5)
                            .font(.inter(size: 12, weight: .semibold))
                            .foregroundColor(currentNetwork.color)
                            .background(
                                Capsule(style: .circular)
                                    .fill(currentNetwork.color.opacity(0.2))
                            )
                    }
                }

                Label {
                    Text(vm.address)
                        .font(.LL.largeTitle3)
                        .fontWeight(.semibold)
                        .foregroundColor(.LL.Neutrals.neutrals6)
                        .padding(.bottom, 20)
                        .colorScheme(.light)
                        .lineLimit(1)
                } icon: {
                    Image("Copy")
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.vertical, 10)
    }

    var shareButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()

            let image = qrCodeContainerView.snapshot()

            let itemSource = ShareActivityItemSource(shareText: vm.address, shareImage: image)

            let activityController = UIActivityViewController(activityItems: [image, vm.address, itemSource], applicationActivities: nil)
            activityController.isModalInPresentation = true
            UIApplication.shared.windows.first?.rootViewController?.presentedViewController?.present(activityController, animated: true, completion: nil)

        } label: {
            Label {
                Text("Share".localized)
                    .font(.LL.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "square.and.arrow.up")
            }
            .foregroundColor(.LL.Neutrals.neutrals6)
            .padding(12)
            .padding(.horizontal, 8)
            .background(.LL.Neutrals.neutrals1)
            .shadow(radius: 10)
            .cornerRadius(16)
            .colorScheme(.light)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

extension WalletReceiveView {
    func doc(text: String, eyeColor: UIColor) -> QRCode.Document {
        let d = QRCode.Document(generator: QRCodeGenerator_External())
        d.utf8String = text
        if let logo = UIImage(named: "lilico-app-icon")?.cgImage {
            let path = CGPath(ellipseIn: CGRect(x: 0.38, y: 0.38, width: 0.24, height: 0.24), transform: nil)
            d.logoTemplate = QRCode.LogoTemplate(image: logo, path: path, inset: 6)
        }

        d.design.backgroundColor(UIColor(hex: "#FAFAFA").cgColor)
        d.design.shape.eye = QRCode.EyeShape.Squircle()
        d.design.style.pupil = QRCode.FillStyle.Solid(eyeColor.cgColor)
        d.design.shape.onPixels = QRCode.PixelShape.Circle(insetFraction: 0.1)
        d.design.style.onPixels = QRCode.FillStyle.Solid(UIColor(hex: "#333333").cgColor)
        return d
    }

    var eyeColor: UIColor {
        currentNetwork.isMainnet ?
            UIColor.LL.Primary.salmonPrimary : UIColor(hex: "#333333")
    }

    var qrCodeView: some View {
        QRCodeDocumentUIView(document: doc(text: vm.address,
                                           eyeColor: eyeColor))
    }
}
