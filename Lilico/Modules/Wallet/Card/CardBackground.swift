//
//  CardBackground.swift
//  Lilico
//
//  Created by Hao Fu on 21/8/2022.
//

import Foundation
import SwiftUI

enum CardBackground: CaseIterable {
    static var allCases: [CardBackground] = [
        .fluid,
        .matrix,
        .color(color: UIColor.LL.Primary.salmonPrimary),
        .fade(imageIndex: 0)]
    
    case color(color: UIColor)
    case image(imageIndex: Int)
    case fade(imageIndex: Int)
    case fluid
    case matrix
    
    @ViewBuilder
    func renderView() -> some View {
        switch self {
        case .fluid:
            FluidView()
        case .matrix:
            MatrixRainView()
        case let .color(color):
            ZStack {
                Color(color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Image("bg-circles")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        case let .fade(imageIndex):
            FadeAnimationBackground(image: fadeList[safe: imageIndex] ?? fadeList[0])
        case let .image(imageIndex):
            (imageList[safe: imageIndex] ?? imageList[0])
                .resizable()
                .aspectRatio(contentMode: .fill)
        }
    }
    
    var imageList: [Image] {
        return [Image("bg-wallet-card")]
    }
    
    var fadeList: [Image] {
        return [Image("flow-line")]
    }
    
    var rawValue: String {
        switch self {
        case let .color(color):
            return identify + ":" + color.hex
        case let .image(imageIndex):
            return identify + ":" + String(imageIndex)
        case let .fade(imageIndex):
            return identify + ":" + String(imageIndex)
        case .fluid:
            return identify
        case .matrix:
            return identify
        }
    }
    
    var identify: String {
        switch self {
        case .color:
            return "color"
        case .image:
            return "image"
        case .fade:
            return "fade"
        case .fluid:
            return "fluid"
        case .matrix:
            return "matrix"
        }
    }
    
    var color: Color {
        switch self {
        case let .color(color):
            return Color(color)
        case .fade:
            return Color.LL.flow
        case .matrix:
            return Color(hex: "#00EF8B")
        default:
            return Color.LL.outline
        }
    }
    
    init(value: String) {
        let list = value.split(separator: ":", omittingEmptySubsequences: true)
        switch list[0] {
        case CardBackground.fluid.identify:
            self = .fluid
        case CardBackground.matrix.identify:
            self = .matrix
        case CardBackground.color(color: .clear).identify:
            guard let hex = list[safe: 1] else {
                self = .color(color: UIColor.LL.bgForIcon)
                return
            }
            self = .color(color: UIColor(hex: String(hex)))
            
        case CardBackground.fade(imageIndex: 0).identify:
            guard let imageString = list[safe: 1], let index = Int(imageString) else {
                self = .fade(imageIndex: 0)
                return
            }
            self = .fade(imageIndex: index)
            
        case CardBackground.image(imageIndex: 0).identify:
            guard let imageString = list[safe: 1], let index = Int(imageString) else {
                self = .image(imageIndex: 0)
                return
            }
            self = .image(imageIndex: index)
        default:
            self = .fade(imageIndex: 0)
        }
    }
    
    struct Key: PreferenceKey {
        public typealias Value = CardBackground
        public static var defaultValue = CardBackground.fluid
        public static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }
}
