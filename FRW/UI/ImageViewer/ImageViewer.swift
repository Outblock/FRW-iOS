//
//  ImageViewer.swift
//  Flow Wallet
//
//  Created by Hao Fu on 5/9/2022.
//

import Kingfisher
import SwiftUI
import UIKit

// MARK: - ImageViewer

@available(iOS 13.0, *)
public struct ImageViewer: View {
    // MARK: Lifecycle

    public init(
        imageURL: String,
        viewerShown: Binding<Bool>,
        backgroundColor: Color = Color(red: 0.12, green: 0.12, blue: 0.12),
        heroAnimation: Namespace.ID,
        aspectRatio: Binding<CGFloat>? = nil,
        caption: Text? = nil,
        closeButtonTopRight: Bool? = false
    ) {
        self.imageURL = imageURL
        self.backgroundColor = backgroundColor
        self.heroAnimation = heroAnimation
        _viewerShown = viewerShown
        self.aspectRatio = aspectRatio
        _caption = State(initialValue: caption)
        _closeButtonTopRight = State(initialValue: closeButtonTopRight)
    }

    // MARK: Public

    @ViewBuilder
    public var body: some View {
        VStack {
            if viewerShown && !imageURL.isEmpty {
                ZStack {
                    VStack {
                        HStack {
                            if self.closeButtonTopRight == true {
                                Spacer()
                            }

                            Button(action: { self.viewerShown = false }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(UIColor.white))
                                    .font(.system(size: UIFontMetrics.default.scaledValue(for: 24)))
                            }

                            if self.closeButtonTopRight != true {
                                Spacer()
                            }
                        }

                        Spacer()
                    }
                    .padding()
                    .zIndex(2)

                    VStack {
                        ZStack {
                            KFImage
                                .url(URL(string: self.imageURL))
                                .placeholder {
                                    Image("placeholder")
                                        .resizable()
                                }
                                .resizable()
                                .aspectRatio(self.aspectRatio?.wrappedValue, contentMode: .fit)
                                .offset(x: self.dragOffset.width, y: self.dragOffset.height)
                                .rotationEffect(.init(degrees: Double(self.dragOffset.width / 30)))
                                .pinchToZoom()
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            self.dragOffset = value.translation
                                            self.dragOffsetPredicted = value.predictedEndTranslation
                                        }
                                        .onEnded { _ in
                                            if (
                                                abs(self.dragOffset.height) +
                                                    abs(self.dragOffset.width) > 270
                                            ) ||
                                                (
                                                    abs(self.dragOffsetPredicted.height) /
                                                        abs(self.dragOffset.height) > 2
                                                ) ||
                                                (
                                                    abs(self.dragOffsetPredicted.width) /
                                                        abs(self.dragOffset.width)
                                                ) > 2 {
                                                withAnimation(.spring()) {
                                                    self.dragOffset = self.dragOffsetPredicted
                                                }
                                                self.viewerShown = false
                                                return
                                            }
                                            withAnimation(.interactiveSpring()) {
                                                self.dragOffset = .zero
                                            }
                                        }
                                )
                                .matchedGeometryEffect(id: "imageView", in: heroAnimation)

                            if self.caption != nil {
                                VStack {
                                    Spacer()

                                    VStack {
                                        Spacer()

                                        HStack {
                                            Spacer()

                                            self.caption
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.center)

                                            Spacer()
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        backgroundColor
                            .opacity(
                                1.0 -
                                    Double(
                                        abs(self.dragOffset.width) +
                                            abs(self.dragOffset.height)
                                    ) /
                                    1000
                            )
                            .edgesIgnoringSafeArea(.all)
                            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
                    )
                    .zIndex(1)
                }
                .animation(.spring(), value: viewerShown)
                .onAppear {
                    self.dragOffset = .zero
                    self.dragOffsetPredicted = .zero
                }
                .onChange(of: viewerShown) { _ in
                    self.dragOffset = .zero
                    self.dragOffsetPredicted = .zero
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Internal

    @Binding
    var viewerShown: Bool
    var imageURL: String
    @State
    var caption: Text?
    @State
    var closeButtonTopRight: Bool?

    var backgroundColor: Color
    var aspectRatio: Binding<CGFloat>?

    @State
    var dragOffset = CGSize.zero
    @State
    var dragOffsetPredicted = CGSize.zero

    var heroAnimation: Namespace.ID
}

// MARK: - PinchZoomView

class PinchZoomView: UIView {
    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        let pinchGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(pinch(gesture:))
        )
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    // MARK: Internal

    weak var delegate: PinchZoomViewDelgate?

    private(set) var scale: CGFloat = 0 {
        didSet {
            delegate?.pinchZoomView(self, didChangeScale: scale)
        }
    }

    private(set) var anchor: UnitPoint = .center {
        didSet {
            delegate?.pinchZoomView(self, didChangeAnchor: anchor)
        }
    }

    private(set) var offset: CGSize = .zero {
        didSet {
            delegate?.pinchZoomView(self, didChangeOffset: offset)
        }
    }

    private(set) var isPinching: Bool = false {
        didSet {
            delegate?.pinchZoomView(self, didChangePinching: isPinching)
        }
    }

    // MARK: Private

    private var startLocation: CGPoint = .zero
    private var location: CGPoint = .zero
    private var numberOfTouches: Int = 0

    @objc
    private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            startLocation = gesture.location(in: self)
            anchor = UnitPoint(
                x: startLocation.x / bounds.width,
                y: startLocation.y / bounds.height
            )
            numberOfTouches = gesture.numberOfTouches

        case .changed:
            if gesture.numberOfTouches != numberOfTouches {
                // If the number of fingers being used changes, the start location needs to be adjusted to avoid jumping.
                let newLocation = gesture.location(in: self)
                let jumpDifference = CGSize(
                    width: newLocation.x - location.x,
                    height: newLocation.y - location.y
                )
                startLocation = CGPoint(
                    x: startLocation.x + jumpDifference.width,
                    y: startLocation.y + jumpDifference.height
                )

                numberOfTouches = gesture.numberOfTouches
            }

            scale = gesture.scale

            location = gesture.location(in: self)
            offset = CGSize(
                width: location.x - startLocation.x,
                height: location.y - startLocation.y
            )

        case .ended, .cancelled, .failed:
            withAnimation(.interactiveSpring()) {
                isPinching = false
                scale = 1.0
                anchor = .center
                offset = .zero
            }

        default:
            break
        }
    }
}

// MARK: - PinchZoomViewDelgate

protocol PinchZoomViewDelgate: AnyObject {
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangePinching isPinching: Bool)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeScale scale: CGFloat)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeAnchor anchor: UnitPoint)
    func pinchZoomView(_ pinchZoomView: PinchZoomView, didChangeOffset offset: CGSize)
}

// MARK: - PinchZoom

struct PinchZoom: UIViewRepresentable {
    class Coordinator: NSObject, PinchZoomViewDelgate {
        // MARK: Lifecycle

        init(_ pinchZoom: PinchZoom) {
            self.pinchZoom = pinchZoom
        }

        // MARK: Internal

        var pinchZoom: PinchZoom

        func pinchZoomView(_: PinchZoomView, didChangePinching isPinching: Bool) {
            pinchZoom.isPinching = isPinching
        }

        func pinchZoomView(_: PinchZoomView, didChangeScale scale: CGFloat) {
            pinchZoom.scale = scale
        }

        func pinchZoomView(_: PinchZoomView, didChangeAnchor anchor: UnitPoint) {
            pinchZoom.anchor = anchor
        }

        func pinchZoomView(_: PinchZoomView, didChangeOffset offset: CGSize) {
            pinchZoom.offset = offset
        }
    }

    @Binding
    var scale: CGFloat
    @Binding
    var anchor: UnitPoint
    @Binding
    var offset: CGSize
    @Binding
    var isPinching: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView()
        pinchZoomView.delegate = context.coordinator
        return pinchZoomView
    }

    func updateUIView(_: PinchZoomView, context _: Context) {}
}

// MARK: - PinchToZoom

struct PinchToZoom: ViewModifier {
    @State
    var scale: CGFloat = 1.0
    @State
    var anchor: UnitPoint = .center
    @State
    var offset: CGSize = .zero
    @State
    var isPinching: Bool = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .offset(offset)
            .overlay(PinchZoom(
                scale: $scale,
                anchor: $anchor,
                offset: $offset,
                isPinching: $isPinching
            ))
    }
}

extension View {
    func pinchToZoom() -> some View {
        modifier(PinchToZoom())
    }
}
