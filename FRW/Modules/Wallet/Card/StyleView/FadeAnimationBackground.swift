//
//  FadeAnimationBackground.swift
//  Flow Wallet
//
//  Created by Hao Fu on 9/8/2022.
//

import SwiftUI
import SwiftUIX

struct FadeAnimationBackground: View {
    
    var image: Image
    var itemPerRow = 8
    @State
    var isAnimating = false
    
    var color: Color = Color.Theme.Accent.green 
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                ForEach(0..<getNumberOfRows(geometry)) { _ in
                    HStack(spacing: 0) {
                        ForEach(0..<itemPerRow + 7) { _ in
                            image
                                .renderingMode(.template)
//                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: UIScreen.screenHeight / CGFloat(getNumberOfRows(geometry)),
                                       height: UIScreen.screenWidth / CGFloat(itemPerRow),
                                       alignment: .center)
                                .opacity(self.isAnimating ? 1 : 0)
                                .animation(
                                    Animation
                                        .linear(duration: .random(in: 1.0...2.0))
                                        .repeatForever(autoreverses: true)
                                        .delay(Double.random(in: 0...1.5)),
                                    value: isAnimating
                                )
                                .padding(.horizontal, 4)
                                .offset(x: -270, y: -30)
                                .foregroundColor(color)
                        }
                    }
                    .rotationEffect(Angle(degrees: 5))
                }
                
            }.onAppear{
                isAnimating = true
            }
            .rotationEffect(Angle(degrees: 20))
        }
        .overlay {
            Color(hex: "#000000", alpha: 0.2)
        }
        .background(Color(hex: "#121212", alpha: 0.9))
//        .ignoresSafeArea()
    }
    
    func getNumberOfRows(_ size: GeometryProxy) -> Int {
        
        let width = UIScreen.screenWidth
        let height = UIScreen.screenHeight
        
        let heightPerItem = width/CGFloat(itemPerRow)
        return Int(height / heightPerItem) + 2
    }
}

struct FadeAnimationBackground_Previews: PreviewProvider {
    static var previews: some View {
        FadeAnimationBackground(image: Image("evm-line"))
        
//        NewEmptyWalletBackgroundView().colorScheme(.dark)
    }
}
