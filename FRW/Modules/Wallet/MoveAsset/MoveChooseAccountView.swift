//
//  MoveChooseAccountView.swift
//  FRW
//
//  Created by cat on 2024/2/27.
//

import SwiftUI

struct MoveChooseAccountView: View {
    var body: some View {
        VStack {
            HStack {
                Text("choose_account".localized)
                    .font(.inter(size: 18, weight: .w700))
                    .foregroundStyle(Color.LL.Neutrals.text)

                Spacer()

                Button {
                    Router.dismiss()
                } label: {
                    Image("icon_close_circle_gray")
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }

            Color.clear
                .frame(height: 20)

            ScrollView {
                MoveUserView()
            }
            .padding(.bottom)
        }
        .padding(.horizontal, 18)
    }
}

#Preview {
    MoveChooseAccountView()
}
