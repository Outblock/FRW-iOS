//
//  BackupSelectOptionsView.swift
//  FRW
//
//  Created by cat on 2023/12/7.
//

import SwiftUI
import SwiftUIX

struct BackupSelectOptionsView: RouteableView {
    
    @StateObject var viewModel: BackupSelectOptionsViewModel
    
    init(list: [BackupType]) {
        _viewModel = StateObject(wrappedValue: BackupSelectOptionsViewModel(backups: list))
    }
    
    var title: String {
        return "multi_backup".localized
    }
    
    
    var body: some View {
        VStack(spacing: 15) {
            VStack {
                Text("multi_backup_guide_title".localized)
                    .font(.inter(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Theme.Accent.grey)
                Text("multi_backup_guide_note".localized)
                    .font(.inter(size: 12))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.Theme.Accent.grey)
            }
            .padding(.horizontal, 40)
            
            
            LazyVGrid(columns: columns(),spacing: 40){
                ForEach(viewModel.list.indices, id:\.self) { index in
                    let item = $viewModel.list[index]
                    ItemView(item: item) { item in
                        onClick(item: item)
                    }
                    .frame(height: 136)
                    
                }
            }
            .padding(.horizontal, 64)
            .padding(.top, 64)
            
            Spacer()
            
            VPrimaryButton(model: ButtonStyle.primary,
                           state: viewModel.nextable ? .enabled : .disabled,
                           action: {
                
            }, title: "next".localized)
            .padding(.horizontal, 18)
            .padding(.bottom)
            
            
        }
        .applyRouteable(self)
        .backgroundFill(Color.LL.Neutrals.background)
    }
    
    func columns() -> [GridItem] {
        let width = (screenWidth - 64 * 2)/2;
       return [GridItem(.adaptive(minimum: width)),
        GridItem(.adaptive(minimum: width))]
    }
    
    func onClick(item: BackupSelectOptionsViewModel.MultiItem) {
        viewModel.onClick(item: item)
    }
}

//MARK: ItemView
extension BackupSelectOptionsView {
    struct ItemView: View {
        @Binding var item: BackupSelectOptionsViewModel.MultiItem
        var onClick:(BackupSelectOptionsViewModel.MultiItem) -> Void
        @Binding private var isSelected: Bool
        
        init(item: Binding<BackupSelectOptionsViewModel.MultiItem>, onClick: @escaping (BackupSelectOptionsViewModel.MultiItem) -> Void) {
            _item = item
            self.onClick = onClick
            _isSelected = item.isBackup
        }
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 24,style: .continuous)
                                                .inset(by: 1)
                                                .stroke(Color.Theme.Accent.green, lineWidth: isSelected ? 2 : 0)
                                                .background(.Theme.Background.white)
                                                .cornerRadius(24)
                        Image(item.icon)
                            .frame(width: 68, height: 68)
                            .padding(.all, 14)
                    }

                    Image("check_circle_border")
                        .resizable()
                        .frame(width:24,height: 24)
                        .offset(x: 6,y:-6)
                        .visibility(isSelected ? .visible : .gone)
                        
                }
                .frame(width: 96, height: 96)
                
                Text(item.name)
                    .font(.inter(size: 14))
                    .foregroundStyle(Color.Theme.Text.black8)
                    .frame(height:24)
            }
            .onTapGesture {
                onClick(item)
            }
        }
    }
}

#Preview {
    
    BackupSelectOptionsView(list: [.google])
    
        
}
