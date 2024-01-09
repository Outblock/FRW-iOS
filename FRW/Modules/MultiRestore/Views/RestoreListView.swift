//
//  RestoreListView.swift
//  FRW
//
//  Created by cat on 2024/1/7.
//

import SwiftUI

struct RestoreListView: RouteableView {
    var title: String {
        return ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("restore".localized)
                        .foregroundColor(Color.Theme.Accent.green)
                        .bold()
                    Text("wallet".localized)
                        .foregroundColor(Color.Theme.Text.black8)
                        .bold()
                }
                .font(.LL.largeTitle)

                Text("restore_from_backup".localized)
                    .font(.LL.body)
                    .foregroundColor(.LL.note)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                RestoreListView.CardView(icon: "restore.icon.device", title: "restore_device_title".localized, des: "restore_device_desc".localized) {
                    Router.route(to: RouteMap.RestoreLogin.syncQC)
                }

                RestoreListView.CardView(icon: "restore.icon.multi", title: "restore_multi_title".localized, des: "restore_multi_desc".localized) {
                    Router.route(to: RouteMap.RestoreLogin.restoreMulti)
                }

                RestoreListView.CardView(icon: "restore.icon.phrase", title: "restore_phrase_title".localized, des: "restore_phrase_desc".localized) {
                    Router.route(to: RouteMap.RestoreLogin.restoreManual)
                }
            }
            .padding(.top, 46)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 28)
        .backgroundFill(Color.LL.background)
        .applyRouteable(self)
    }
}

extension RestoreListView {
    struct CardView: View {
        var icon: String
        var title: String
        var des: String
        var onClick: () -> Void
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Image(icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text(title)
                        .font(.inter(size: 16, weight: .semibold))
                        .foregroundStyle(Color.Theme.Accent.grey)
                    Text(des)
                        .font(.inter(size: 12))
                        .foregroundStyle(Color.Theme.Accent.grey)
                }
                Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.leading, 32)
            .padding(.trailing, 12)
            .background(Color.Theme.Line.line)
            .cornerRadius(16)
            .onTapGesture {
                onClick()
            }
        }
    }
}

#Preview {
    RestoreListView()
//    RestoreListView.CardView(icon: "restore.icon.device", title: "From Device Backup", des: "Mobile or Extension Devices")
}
