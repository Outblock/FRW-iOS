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
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("things_you".localized)
                    .font(.inter(size: 36, weight: .heavy))
                    .foregroundColor(Color.Theme.Text.black)
                HStack {
                    Text("need_to".localized)
                        .font(.inter(size: 36, weight: .heavy))
                        .foregroundColor(Color.Theme.Text.black)

                    Text("know".localized)
                        .font(.inter(size: 36, weight: .heavy))
                        .foregroundColor(Color.Theme.Accent.green)
                }

                Text("secret_phrase_tips".localized)
                    .font(.inter(size: 14))
                    .foregroundColor(.Theme.Text.black8)
                    .padding(.top, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                TextCheckListView(titles: [
                    "multi_check_phrase_1".localized,
                    "multi_check_phrase_2".localized,
                    "multi_check_phrase_3".localized
                ], allChecked: $allCheck)
            }
            .padding(.top, 24)
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
