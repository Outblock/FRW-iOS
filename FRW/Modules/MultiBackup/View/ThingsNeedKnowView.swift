//
//  ThingsNeedKnowView.swift
//  FRW
//
//  Created by cat on 2024/9/19.
//

import SwiftUI

struct ThingsNeedKnowView: RouteableView {
    var title: String {
        return ""
    }
    
    @State var allCheck = false
    
    var buttonState: VPrimaryButtonState {
        return allCheck ? .enabled : .disabled
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("things_you".localized)
                    .font(.LL.largeTitle)
                    .bold()
                    .foregroundColor(Color.LL.rebackground)
                HStack {
                    Text("need_to".localized)
                        .bold()
                        .foregroundColor(Color.LL.rebackground)

                    Text("know".localized)
                        .bold()
                        .foregroundColor(Color.LL.orange)
                }
                .font(.LL.largeTitle)

                Text("secret_phrase_tips".localized)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
                    .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                TextCheckListView(titles: [
                    "multi_check_phrase_1".localized,
                    "multi_check_phrase_2".localized,
                    "multi_check_phrase_3".localized
                ], allChecked: $allCheck)
            }
            Spacer()
            VPrimaryButton(model: ButtonStyle.primary,
                           state: buttonState,
                           action: {
                onConfirm()
            }, title: "confirm_tag".localized)
            .padding(.bottom)
        }
        .padding(.horizontal, 28)
        .background(Color.LL.background, ignoresSafeAreaEdges: .all)
        .applyRouteable(self)
    }
    
    func onConfirm() {
        Router.route(to: RouteMap.Backup.createPhraseBackup)
    }
}

#Preview {
    ThingsNeedKnowView()
}
