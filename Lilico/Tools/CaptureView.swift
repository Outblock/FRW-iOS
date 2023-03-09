//
//  CaptureView.swift
//  Sky
//
//  Created by cat on 2022/6/6.
//

import SwiftUI

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: edgesIgnoringSafeArea(.all))
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension CGRect {
    var uiImage: UIImage? {
        UIApplication.shared.windows
            .filter { $0.isKeyWindow }
            .first?.rootViewController?.view
            .asImage(rect: self)
    }
}

extension View {
    func getRect(_ rect: Binding<CGRect>) -> some View {
        modifier(GetRect(rect: rect))
    }
}

struct GetRect: ViewModifier {
    @Binding var rect: CGRect

    var measureRect: some View {
        GeometryReader { proxy in
            Rectangle().fill(Color.clear)
                .preference(key: RectPreferenceKey.self, value: proxy.frame(in: .global))
        }
    }

    func body(content: Content) -> some View {
        content
            .background(measureRect)
            .onPreferenceChange(RectPreferenceKey.self) { rect in
                if let rect = rect {
                    self.rect = rect
                }
            }
    }
}

extension GetRect {
    struct RectPreferenceKey: PreferenceKey {
        static func reduce(value _: inout CGRect?, nextValue _: () -> CGRect?) {
//            value = nextValue()
        }

        typealias Value = CGRect?

        static var defaultValue: CGRect? = nil
    }
}

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
