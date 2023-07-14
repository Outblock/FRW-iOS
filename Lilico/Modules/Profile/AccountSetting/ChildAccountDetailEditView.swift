//
//  ChildAccountDetailEditView.swift
//  Lilico
//
//  Created by Selina on 13/7/2023.
//

import SwiftUI
import Combine
import UIKit
import Kingfisher
import SwiftUIX

extension ChildAccountDetailEditViewModel {
    class NewAccountInfo {
        var newImage: UIImage?
    }
}

class ChildAccountDetailEditViewModel: ObservableObject {
    @Published var childAccount: ChildAccount
    @Published var imagePickerShowFlag = false
    @Published var newInfo: NewAccountInfo = NewAccountInfo()
    
    init(childAccount: ChildAccount) {
        self.childAccount = childAccount
    }
    
    @objc func saveAction() {
        log.debug("save save")
    }
    
    func pickAvatarAction() {
        imagePickerShowFlag = true
    }
}

struct ChildAccountDetailEditView: RouteableView {
    @StateObject var vm: ChildAccountDetailEditViewModel
    
    init(vm: ChildAccountDetailEditViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var title: String {
        "edit".localized
    }
    
    func configNavigationItem(_ navigationItem: UINavigationItem) {
        let saveBtn = UIButton(type: .custom)
        let bgImage = UIImage.image(withColor: UIColor(named: "button.color")!)
        let textColor = UIColor(named: "button.text")
        saveBtn.setBackgroundImage(bgImage, for: .normal)
        saveBtn.setTitleColor(textColor, for: .normal)
        saveBtn.setTitle("save".localized)
        saveBtn.titleLabel?.font = .interSemiBold(size: 14)
        saveBtn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        saveBtn.sizeToFit()
        saveBtn.clipsToBounds = true
        saveBtn.layer.cornerRadius = saveBtn.bounds.height / 2
        saveBtn.addTarget(vm, action: Selector("saveAction"), for: .touchUpInside)
        
        let saveItem = UIBarButtonItem(customView: saveBtn)
        navigationItem.rightBarButtonItem = saveItem
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                avatarEditCell
                divider
                nameEditCell
                divider
                descEditCell
            }
            .background(Color.LL.bgForIcon)
            .cornerRadius(16)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundFill(Color.LL.Neutrals.background)
        .applyRouteable(self)
        .sheet(isPresented: $vm.imagePickerShowFlag) {
            ImagePicker(image: $vm.newInfo.newImage)
        }
    }
    
    var avatarEditCell: some View {
        Button {
            vm.pickAvatarAction()
        } label: {
            HStack(spacing: 0) {
                Text("avatar".localized)
                    .font(.inter(size: 16, weight: .medium))
                    .foregroundColor(Color.LL.Neutrals.text)
                
                Spacer()
                
                if let image = vm.newInfo.newImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                        .padding(.trailing, 15)
                } else {
                    KFImage.url(URL(string: vm.childAccount.icon))
                        .placeholder({
                            Image("placeholder")
                                .resizable()
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(25)
                        .padding(.trailing, 15)
                }
                
                Image("icon-black-right-arrow")
                    .renderingMode(.template)
                    .foregroundColor(Color.LL.Neutrals.text2)
            }
            .padding(.all, 16)
        }
    }
    
    var nameEditCell: some View {
        HStack(spacing: 16) {
            Text("name".localized)
                .font(.inter(size: 16, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
            
            Spacer()
            
            Text(vm.childAccount.name)
                .font(.inter(size: 16))
                .foregroundColor(Color.LL.Neutrals.note)
                .multilineTextAlignment(.leading)
        }
        .padding(.all, 16)
    }
    
    var descEditCell: some View {
        HStack(spacing: 16) {
            Text("description".localized)
                .font(.inter(size: 16, weight: .medium))
                .foregroundColor(Color.LL.Neutrals.text)
            
            Spacer()
            
            Text(vm.childAccount.description)
                .font(.inter(size: 16))
                .foregroundColor(Color.LL.Neutrals.note)
                .multilineTextAlignment(.leading)
        }
        .padding(.all, 16)
    }
                      
    
    var divider: some View {
        Divider()
            .foregroundColor(.LL.Neutrals.background)
            .padding(.horizontal, 16)
    }
}
