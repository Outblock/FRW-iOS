//
//  MoveComponentView.swift
//  FRW
//
//  Created by cat on 2024/10/11.
//

import Kingfisher
import SwiftUI

typealias ContactCallback = (Contact) -> Void

// MARK: - ContactRelationView

struct ContactRelationView: View {
    enum Clickable {
        case none
        case from
        case to
        case all
    }

    var fromContact: Contact
    var toContact: Contact
    var clickable: Clickable = .none

    var clickFrom: ContactCallback?
    var clickTo: ContactCallback?
    
    var clickSwap: (() -> Void)?

    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                userCard(contact: fromContact, showArrow: clickable == .from || clickable == .all) {
                    UIImpactFeedbackGenerator.impactOccurred(.selectionChanged)
                    clickFrom?(fromContact)
                }
                .frame(maxWidth: .infinity)

                userCard(contact: toContact, showArrow: clickable == .to || clickable == .all) {
                    UIImpactFeedbackGenerator.impactOccurred(.selectionChanged)
                    clickTo?(toContact)
                }
                .frame(maxWidth: .infinity)
            }
            
            Button {
                UIImpactFeedbackGenerator.impactOccurred(.selectionChanged)
                clickSwap?()
            } label: {
                arrow()
            }
        }
    }

    @ViewBuilder
    func userCard(
        contact: Contact,
        showArrow: Bool = false,
        onClick: (() -> Void)? = nil
    ) -> some View {
        Button {
            if showArrow {
                onClick?()
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let user = contact.user {
                        user.emoji.icon(size: 32)
                    } else {
                        KFImage.url(URL(string: contact.avatar ?? ""))
                            .placeholder {
                                Image("placeholder")
                                    .resizable()
                            }
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .cornerRadius(16)
                    }
                    
                    TagView(type: contact.walletType ?? .flow)
                    
                    Spacer()
                    
                    Image("icon_arrow_bottom_16")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .visibility(showArrow ? .visible : .gone)
                }
                
                Text(contact.displayName)
                    .font(.inter(size: 14, weight: .semibold))
                    .foregroundStyle(Color.Theme.Text.black)
                    .frame(height: 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(contact.address ?? "")
                    .font(.inter(size: 12))
                    .truncationMode(.middle)
                    .foregroundStyle(Color.Theme.Text.black8)
                    .frame(height: 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(.Theme.BG.bg3)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }

    @ViewBuilder
    func arrow() -> some View {
        Image("icon-account-swap")
            .resizable()
            .frame(width: 25, height: 25)
            .padding(6)
            .background(Color.Theme.BG.bg1)
            .cornerRadius(20)
    }
}

// MARK: - MoveFeeView

struct MoveFeeView: View {
    var isFree = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("move_fee".localized)
                    .font(.inter(size: 12, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
                Spacer()
                Text(feeBalance())
                    .font(.inter(size: 12, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
            }
            .frame(height: 16)
            Text(feeHint())
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .font(.inter(size: 12, weight: .bold))
                .foregroundStyle(Color.Theme.Text.black6)
        }
    }

    func feeBalance() -> String {
        isFree ? "0.00 FLOW" : ("move_fee_cost".localized + " FLOW")
    }

    func feeHint() -> String {
        isFree ? "move_fee_hint_free".localized : "move_fee_hint_cost".localized
    }
}

#Preview {
    Group {
        ContactRelationView(
            fromContact: Contact(
                address: "0x123",
                avatar: nil,
                contactName: "abc",
                contactType: .user,
                domain: nil,
                id: 1,
                username: "",
                walletType: .evm
            ),
            toContact: Contact(
                address: "0xabc",
                avatar: nil,
                contactName: "123",
                contactType: .user,
                domain: nil,
                id: 1,
                username: "",
                walletType: .link
            )
        )
        .background(Color.Theme.Accent.grey)
        MoveFeeView(isFree: true)
        Divider()
        MoveFeeView(isFree: false)
    }
}
