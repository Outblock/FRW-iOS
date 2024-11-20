//
//  GetHeightModifier.swift
//  FRW
//
//  Created by Antonio Bello on 11/19/24.
//

import SwiftUI

struct GetHeightModifier: ViewModifier {
    @Binding var height: CGFloat
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        self.height = proxy.size.height
                    }
            }
        }
    }
}

extension View {
    func getHeight(_ height: Binding<CGFloat>) -> some View {
        modifier(GetHeightModifier(height: height))
    }
}
