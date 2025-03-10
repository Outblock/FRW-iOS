//
//  VRangeSlider.swift
//  VComponents
//
//  Created by Vakhtang Kontridze on 1/12/21.
//

import SwiftUI

// MARK: - VRangeSlider

/// Value picker component that selects values from a bounded linear range of values to represent a range.
///
/// Model, range, step, state, and onChange callbacks can be passed as parameters.
///
/// If invalid value parameters are passed during init, layout would invalidate itself, and refuse to draw.
///
/// Usage example:
///
///     @State var valueLow: Double = 0.3
///     @State var valueHigh: Double = 0.8
///
///     var body: some View {
///         VRangeSlider(
///             difference: 0.1,
///             valueLow: $valueLow,
///             valueHigh: $valueHigh
///         )
///     }
///
public struct VRangeSlider: View {
    // MARK: Lifecycle

    // MARK: Initializers

    /// Initializes component with diffrene, and low and high values.
    public init<V>(
        model: VRangeSliderModel = .init(),
        range: ClosedRange<V> = 0...1,
        difference: V,
        step: V? = nil,
        state: VRangeSliderState = .enabled,
        valueLow: Binding<V>,
        valueHigh: Binding<V>,
        onChangeLow actionLow: ((Bool) -> Void)? = nil,
        onChangeHigh actionHigh: ((Bool) -> Void)? = nil
    )
        where
        V: BinaryFloatingPoint,
        V.Stride: BinaryFloatingPoint {
        self.model = model
        self.min = .init(range.lowerBound)
        self.max = .init(range.upperBound)
        self.difference = .init(difference)
        self.step = step.let { .init($0) }
        self.state = state
        _valueLow = .init(from: valueLow, range: range, step: step)
        _valueHigh = .init(from: valueHigh, range: range, step: step)
        self.actionLow = actionLow
        self.actionHigh = actionHigh

        self.isLayoutValid = valueLow.wrappedValue <= valueHigh.wrappedValue - difference
    }

    // MARK: Public

    // MARK: Body

    public var body: some View {
        syncInternalStateWithState()

        return Group(content: {
            switch isLayoutValid {
            case false: invalidBody
            case true: validBody
            }
        })
        .padding(.horizontal, model.layout.thumbDimension / 2)
    }

    // MARK: Fileprivate

    // MARK: Thumb

    fileprivate enum Thumb { case low, high }

    // MARK: Private

    // MARK: Properties

    private let model: VRangeSliderModel

    private let min, max: Double
    private let difference: Double
    private let step: Double?

    private let state: VRangeSliderState

    @Binding
    private var valueLow: Double
    @Binding
    private var valueHigh: Double
    @State
    private var animatableValueLow: Double?
    @State
    private var animatableValueHigh: Double?

    private let actionLow: ((Bool) -> Void)?
    private let actionHigh: ((Bool) -> Void)?

    private let isLayoutValid: Bool

    private var range: ClosedRange<Double> { min...max }
    private var invalidBody: some View {
        track
            .mask(RoundedRectangle(cornerRadius: model.layout.cornerRadius))
            .frame(height: model.layout.height)
    }

    private var validBody: some View {
        GeometryReader(content: { proxy in
            ZStack(alignment: .leading, content: {
                track
                progress(in: proxy)
            })
            .mask(RoundedRectangle(cornerRadius: model.layout.cornerRadius))
            .overlay(thumb(in: proxy, thumb: .low))
            .overlay(thumb(in: proxy, thumb: .high))
            .disabled(!state.isEnabled)
        })
        .frame(height: model.layout.height)
    }

    private var track: some View {
        Rectangle()
            .foregroundColor(model.colors.track.for(state))
    }

    private func progress(in proxy: GeometryProxy) -> some View {
        Rectangle()
            .padding(.leading, progress(in: proxy, thumb: .low))
            .padding(.trailing, progress(in: proxy, thumb: .high))
            .foregroundColor(model.colors.progress.for(state))
    }

    private func thumb(in proxy: GeometryProxy, thumb: Thumb) -> some View {
        Group(content: {
            ZStack(content: {
                RoundedRectangle(cornerRadius: model.layout.thumbCornerRadius)
                    .foregroundColor(model.colors.thumb.for(state))
                    .shadow(
                        color: model.colors.thumbShadow.for(state),
                        radius: model.layout.thumbShadowRadius
                    )

                RoundedRectangle(cornerRadius: model.layout.thumbCornerRadius)
                    .strokeBorder(
                        model.colors.thumbBorder.for(state),
                        lineWidth: model.layout.thumbBorderWidth
                    )
            })
            .frame(dimension: model.layout.thumbDimension)
            .offset(x: thumbOffset(in: proxy, thumb: thumb))
        })
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        ) // Must be put into group, as content already has frame
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { dragChanged(drag: $0, in: proxy, thumb: thumb) }
                .onEnded { dragEnded(drag: $0, thumb: thumb) }
        )
    }

    // MARK: State Syncs

    private func syncInternalStateWithState() {
        DispatchQueue.main.async {
            if animatableValueLow == nil || animatableValueLow != valueLow {
                withAnimation(model.animations.progress) { animatableValueLow = valueLow }
            }

            if animatableValueHigh == nil || animatableValueHigh != valueHigh {
                withAnimation(model.animations.progress) { animatableValueHigh = valueHigh }
            }
        }
    }

    // MARK: Drag

    private func dragChanged(drag: DragGesture.Value, in proxy: GeometryProxy, thumb: Thumb) {
        let rawValue: Double = {
            let value: Double = .init(drag.location.x)
            let range: Double = max - min
            let width: Double = .init(proxy.size.width)

            return min + (value / width) * range
        }()

        let valueFixed: Double = {
            switch thumb {
            case .low:
                return rawValue.fixedInRange(
                    min: min,
                    max: Swift.min((valueHigh - difference).roundedDownWithStep(step), max),
                    step: step
                )

            case .high:
                return rawValue.fixedInRange(
                    min: Swift.max((valueLow + difference).roundedUpWithStep(step), min),
                    max: max,
                    step: step
                )
            }
        }()

        switch thumb {
        case .low: setValueLow(to: valueFixed)
        case .high: setValueHigh(to: valueFixed)
        }

        switch thumb {
        case .low: actionLow?(true)
        case .high: actionHigh?(true)
        }
    }

    private func dragEnded(drag _: DragGesture.Value, thumb: Thumb) {
        switch thumb {
        case .low: actionLow?(false)
        case .high: actionHigh?(false)
        }
    }

    // MARK: Actions

    private func setValueLow(to value: Double) {
        withAnimation(model.animations.progress) { animatableValueLow = value }
        valueLow = value
    }

    private func setValueHigh(to value: Double) {
        withAnimation(model.animations.progress) { animatableValueHigh = value }
        valueHigh = value
    }

    // MARK: Progress

    private func progress(in proxy: GeometryProxy, thumb: Thumb) -> CGFloat {
        let value: CGFloat = {
            switch thumb {
            case .low: return .init((animatableValueLow ?? valueLow) - min)
            case .high: return .init((animatableValueHigh ?? valueHigh) - min)
            }
        }()
        let range: CGFloat = .init(max - min)
        let width: CGFloat = proxy.size.width

        switch thumb {
        case .low: return (value / range) * width
        case .high: return ((range - value) / range) * width
        }
    }

    // MARK: Thumb

    private func thumbOffset(in proxy: GeometryProxy, thumb: Thumb) -> CGFloat {
        let progressW: CGFloat = progress(in: proxy, thumb: thumb)
        let thumbW: CGFloat = model.layout.thumbDimension
        let width: CGFloat = proxy.size.width

        switch thumb {
        case .low: return progressW - thumbW / 2
        case .high: return width - progressW - thumbW / 2
        }
    }
}

// MARK: - VRangeSlider_Previews

struct VRangeSlider_Previews: PreviewProvider {
    // MARK: Internal

    static var previews: some View {
        VRangeSlider(difference: 0.1, valueLow: $valueLow, valueHigh: $valueHigh)
            .padding()
    }

    // MARK: Private

    @State
    private static var valueLow: Double = 0.1
    @State
    private static var valueHigh: Double = 0.8
}

// MARK: - Helpers

extension Double {
    fileprivate func roundedUpWithStep(
        _ step: Double?
    ) -> Double {
        guard let step = step else { return self }
        return ceil(self / step) * step
    }

    fileprivate func roundedDownWithStep(
        _ step: Double?
    ) -> Double {
        guard let step = step else { return self }
        return floor(self / step) * step
    }
}
