//
//  ColorsFromImage.swift
//  Lilico
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
}


enum ImageHelper {
    
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
