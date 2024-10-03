//
//  BackupUploadTimeline.swift
//  FRW
//
//  Created by cat on 2023/12/14.
//

import SwiftUI

struct BackupUploadTimeline: View {
    var backupType: MultiBackupType
    var isError: Bool
    var process: BackupProcess

    var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader(content: { geometry in
                Divider()
                    .frame(width: 1, height: geometry.size.height - 24)
                    .overlay(lineColor)
                    .offset(x: 3, y: 12)
            })
            .layoutPriority(-1)

            VStack(alignment: .leading, spacing: 0) {
                BackupUploadTimeline.Item(title: "backup.upload.key.x".localized(backupType.title),
                                          backupType: backupType,
                                          isError: isError,
                                          process: .upload,
                                          currentProcess: process)
                Spacer()
                BackupUploadTimeline.Item(title: "backup.register.key".localized,
                                          backupType: backupType,
                                          isError: isError,
                                          process: .regist,
                                          currentProcess: process)
            }
        }
        .frame(height: 120)
    }

    var lineColor: Color {
        (process == .regist || process == .finish) ? Color.Theme.Text.black8 : Color.Theme.Text.black3
    }
}

extension BackupUploadTimeline {
    struct Item: View {
        var title: String
        var backupType: MultiBackupType = .google
        var isError: Bool = true
        var process: BackupProcess
        var currentProcess: BackupProcess

        var body: some View {
            HStack {
                Circle()
                    .cornerRadius(4)
                    .frame(width: 8, height: 8)
                    .foregroundColor(themeColor())
                    .background(.clear)
                Text(title)
                    .font(.inter(size: 14))
                    .lineLimit(1)
                    .foregroundColor(themeColor())
                Image(isError && process == currentProcess ? "backup.status.error" : "backup.status.finish")
                    .visibility(showIcon() ? .visible : .gone)
            }
        }

        func themeColor() -> Color {
            if isError && process == currentProcess {
                return Color.Theme.Accent.red
            }
            if process == currentProcess || process.next == currentProcess {
                return Color.Theme.Text.black8
            }
            return Color.Theme.Text.black3
        }

        func showIcon() -> Bool {
            isError || currentProcess == process.next
        }
    }
}

#Preview {
    BackupUploadTimeline(backupType: .google, isError: false, process: .regist)
}
