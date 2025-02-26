//
//  AccountCreatedView.swift
//  FRW
//
//  Created by Marty Ulrich on 2/22/25.
//

import SwiftUI

struct AccountCreatedView: RouteableView {
    init(_ viewModel: CreateProfileWaitingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Internal

    @StateObject
    var viewModel: CreateProfileWaitingViewModel

    var title: String {
        ""
    }

    var isNavigationBarHidden: Bool {
        true
    }
    
    var body: some View {
        VStack {
            flowLabel
                .padding(.leading, 32)
            
            Spacer()
            
            Text("account_ready".localized)
                .font(.Ukraine(size: 40, weight: .light))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.Theme.Text.black)
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            
            subtitleAndGradient
                .padding(.leading, 32)
            
            Spacer()
            
            createBackupBtn
                .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .backgroundFill(Color.Theme.Background.grey)
    }
    
    // MARK: Private
    
    @ViewBuilder
    private var subtitleAndGradient: some View {
        ZStack(alignment: .bottomTrailing) {
            HStack {
                Spacer()
                Image("create_profile_bg")
                    .frame(width: 343, alignment: .bottomTrailing)
                    .offset(CGPoint(x: 60, y: 0))
            }
            Text("backing_up_your_account".localized)
                .font(.inter(size: 18, weight: .light))
                .foregroundStyle(Color.Theme.Text.black8)
                .padding([.bottom, .trailing], 24)
                .padding(.trailing, 80)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var createBackupBtn: some View {
        Button {
            viewModel.onCreateBackup()
        } label: {
            HStack {
                Text("create_backup".localized)
                    .font(.inter(size: 14, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.white9)
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.Theme.Accent.green)
            .cornerRadius(16)
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private var flowLabel: some View {
        HStack {
            Image("lilico-app-icon")
                .resizable()
                .frame(width: 32, height: 32)
            Text("app_name_full".localized)
                .font(.inter(size: 18, weight: .semibold))
                .foregroundStyle(Color.Theme.Text.black)
            Spacer()
        }
    }
}

#Preview {
    AccountCreatedView(CreateProfileWaitingViewModel(txId: "", callback: { _, _ in }))
}
