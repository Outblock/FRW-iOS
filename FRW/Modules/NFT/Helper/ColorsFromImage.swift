//
//  ColorsFromImage.swift
//  Flow Wallet
//
//  Created by cat on 2022/6/8.
//

import Foundation
import SwiftUI
import ColorKit
import Kingfisher

extension UIImage {
    func colors() async -> [Color] {
//        return await withCheckedContinuation { continuation in
//            DispatchQueue.global().async {
//                guard let colors = ColorThief.getPalette(from: self, colorCount: 6, quality: 1, ignoreWhite: false) else {
//                    DispatchQueue.main.async {
//                        continuation.resume(returning: [])
//                    }
//
//                    return
//                }
//                DispatchQueue.main.async {
//                    let result = colors.map { Color(uiColor: $0.makeUIColor()) }
//                    continuation.resume(returning: result)
//                }
//            }
//        }
        
        guard let colors = try? dominantColors(),
              let palette = ColorPalette(orderedColors: colors, ignoreContrastRatio: true) else {
            return [.LL.text]
        }
        
        return [Color(palette.background), Color(palette.primary), (palette.secondary != nil) ? Color(palette.secondary!) : .LL.text]
    }
    
    func mostFrequentColor() -> Color? {
        guard let cgImage = self.cgImage else { return nil }

        // 把图片缩小以加快处理速度
        let width = 100
        let height = Int(CGFloat(cgImage.height) * CGFloat(100) / CGFloat(cgImage.width))
        
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let pixelData = context.data else { return nil }

        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)
        let length = width * height

        var colorCounts: [UInt32: Int] = [:]

        for i in 0..<length {
            let pixelIndex = i * 4
            let r = data[pixelIndex]
            let g = data[pixelIndex + 1]
            let b = data[pixelIndex + 2]
            let a = data[pixelIndex + 3]

            // 忽略透明像素
            if a > 0 {
                let color = (UInt32(r) << 24) | (UInt32(g) << 16) | (UInt32(b) << 8) | UInt32(a)
                colorCounts[color, default: 0] += 1
            }
        }

        if let (mostFrequentColor, _) = colorCounts.max(by: { $0.value < $1.value }) {
            let r = CGFloat((mostFrequentColor >> 24) & 0xFF) / 255.0
            let g = CGFloat((mostFrequentColor >> 16) & 0xFF) / 255.0
            let b = CGFloat((mostFrequentColor >> 8) & 0xFF) / 255.0
            let a = CGFloat(mostFrequentColor & 0xFF) / 255.0

            return Color(red: r, green: g, blue: b, opacity: a)
        }

        return nil
    }
}


enum ImageHelper {
    
    static func mostFrequentColor(from url: String) async -> Color {
        return await withCheckedContinuation { continuation in
            ImageCache.default.retrieveImage(forKey: url) { result in
                switch result {
                case let .success(value):
                    Task {
                        guard let image = value.image,
                              let color = image.mostFrequentColor() else {
                            continuation.resume(returning: Color.LL.text)
                            return
                        }
                        continuation.resume(returning: color )
                    }

                case .failure:
                    continuation.resume(returning: Color.LL.text)
                }
            }
        }
    }
    
    static func colors(from url: String) async -> [Color] {
        return await withCheckedContinuation { continuation in
            ImageCache.default.retrieveImage(forKey: url) { result in
                switch result {
                case let .success(value):
                    Task {
                        guard let image = value.image else {
                            continuation.resume(returning: [Color.LL.background, Color.LL.text, Color.LL.outline])
                            return
                        }
                        let colors = await image.colors()
                        continuation.resume(returning: colors)
                    }

                case .failure:
                    continuation.resume(returning: [Color.LL.background, Color.LL.text, Color.LL.outline])
                }
            }
        }
    }
    
    static func image(from url: String) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            ImageCache.default.retrieveImage(forKey: url) { result in
                switch result {
                case let .success(value):
                    continuation.resume(returning: value.image)

                case .failure:
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
}

