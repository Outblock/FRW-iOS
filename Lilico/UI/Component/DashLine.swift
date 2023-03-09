//
//  DashLine.swift
//  Lilico
//
//  Created by cat on 2022/6/6.
//

import SwiftUI

struct VDashLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
    }
}

struct HDashLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        }
    }
}

struct DashLine_Previews: PreviewProvider {
    static var previews: some View {
        HDashLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .frame(height: 1)
            .foregroundColor(Color.orange)

        VDashLine().stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
            .frame(width: 1)
            .foregroundColor(Color.orange)
    }
}
