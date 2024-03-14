//
//  ProfileEditNameView.swift
//  Flow Wallet
//
//  Created by Selina on 14/6/2022.
//

import SwiftUI

struct ProfileEditNameView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditNameView()
    }
}

struct ProfileEditNameView: RouteableView {
    @StateObject private var vm = ProfileEditNameViewModel()
    
    var title: String {
        return "edit_nickname".localized
    }

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                nameField
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationBarItems(trailing: HStack {
            Button {
                vm.trigger(.save)
            } label: {
                Text("save".localized)
            }
            .buttonStyle(.plain)
            .foregroundColor(.LL.Primary.salmonPrimary)
            .disabled(vm.status != .ok)
        })
        .backgroundFill(.LL.Neutrals.background)
        .applyRouteable(self)
    }
}

extension ProfileEditNameView {
    var nameField: some View {
        VStack(alignment: .leading) {
            ZStack {
                TextField("name".localized, text: $vm.name).frame(height: 50)
            }
            .padding(.horizontal, 10)
            .border(Color.LL.Neutrals.text, cornerRadius: 6)
        }
    }
}
