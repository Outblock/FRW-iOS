//
//  HeartImageView.swift
//  SwiftUI-Animations
//
//  Created by Shubham Singh on 26/09/20.
//  Copyright © 2020 Shubham Singh. All rights reserved.
//

import SwiftUI

struct HeartImageView: View {
    
    @Binding
    var isLike: Bool
    
    var body: some View {
        Image(isLike ? "icon-star-fill" : "icon-star")
            .renderingMode(.template)
            .font(.system(size: 120, weight: .medium, design: .rounded))
    }
}

struct HeartImageView_Previews: PreviewProvider {
    static var previews: some View {
        HeartImageView(isLike: .constant(false))
    }
}
