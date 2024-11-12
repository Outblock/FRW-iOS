//
//  FluidGradient.swift
//  FluidGradient
//
//  Created by Oskar Groth on 2021-12-23.
//

import SwiftUI

// MARK: - FluidGradient

public struct FluidGradient: View {
    // MARK: Lifecycle

    public init(
        blobs: [Color],
        highlights: [Color] = [],
        speed: CGFloat = 1.0,
        blur: CGFloat = 0.75
    ) {
        self.blobs = blobs
        self.highlights = highlights
        self.speed = speed
        self.blur = blur
    }

    // MARK: Public

    public var body: some View {
        Representable(
            blobs: blobs,
            highlights: highlights,
            speed: speed,
            blurValue: $blurValue
        )
        .blur(radius: pow(blurValue, blur))
        .accessibility(hidden: true)
        .clipped()
    }

    // MARK: Internal

    @State
    var blurValue: CGFloat = 0.0

    // MARK: Private

    private var blobs: [Color]
    private var highlights: [Color]
    private var speed: CGFloat
    private var blur: CGFloat
}

#if os(OSX)
typealias SystemRepresentable = NSViewRepresentable
#else
typealias SystemRepresentable = UIViewRepresentable
#endif

// MARK: - Representable

extension FluidGradient {
    struct Representable: SystemRepresentable {
        var blobs: [Color]
        var highlights: [Color]
        var speed: CGFloat

        @Binding
        var blurValue: CGFloat

        func makeView(context: Context) -> FluidGradientView {
            context.coordinator.view
        }

        func updateView(_: FluidGradientView, context: Context) {
            context.coordinator.create(blobs: blobs, highlights: highlights)
            DispatchQueue.main.async {
                context.coordinator.update(speed: speed)
            }
        }

        #if os(OSX)
        func makeNSView(context: Context) -> FluidGradientView {
            makeView(context: context)
        }

        func updateNSView(_ view: FluidGradientView, context: Context) {
            updateView(view, context: context)
        }
        #else
        func makeUIView(context: Context) -> FluidGradientView {
            makeView(context: context)
        }

        func updateUIView(_ view: FluidGradientView, context: Context) {
            updateView(view, context: context)
        }
        #endif

        func makeCoordinator() -> Coordinator {
            Coordinator(
                blobs: blobs,
                highlights: highlights,
                speed: speed,
                blurValue: $blurValue
            )
        }
    }

    class Coordinator: FluidGradientDelegate {
        // MARK: Lifecycle

        init(
            blobs: [Color],
            highlights: [Color],
            speed: CGFloat,
            blurValue: Binding<CGFloat>
        ) {
            self.blobs = blobs
            self.highlights = highlights
            self.speed = speed
            self.blurValue = blurValue
            self.view = FluidGradientView(
                blobs: blobs,
                highlights: highlights,
                speed: speed
            )
            view.delegate = self
        }

        // MARK: Internal

        var blobs: [Color]
        var highlights: [Color]
        var speed: CGFloat
        var blurValue: Binding<CGFloat>

        var view: FluidGradientView

        /// Create blobs and highlights
        func create(blobs: [Color], highlights: [Color]) {
            guard blobs != self.blobs || highlights != self.highlights else { return }
            self.blobs = blobs
            self.highlights = highlights

            view.create(blobs, layer: view.baseLayer)
            view.create(highlights, layer: view.highlightLayer)
            view.update(speed: speed)
        }

        /// Update speed
        func update(speed: CGFloat) {
            guard speed != self.speed else { return }
            self.speed = speed
            view.update(speed: speed)
        }

        func updateBlur(_ value: CGFloat) {
            blurValue.wrappedValue = value
        }
    }
}
