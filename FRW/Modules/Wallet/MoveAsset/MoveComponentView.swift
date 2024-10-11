//
//  MoveComponentView.swift
//  FRW
//
//  Created by cat on 2024/10/11.
//

import SwiftUI
import Kingfisher

typealias ContactCallback = (Contact)->()

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
    
    var body: some View {
        ZStack {
            HStack(spacing: 20) {
                userCard(contact: fromContact, showArrow: (clickable == .from || clickable == .all)) {
                    clickFrom?(fromContact)
                }
                    .frame(maxWidth: .infinity)
                
                userCard(contact: toContact, showArrow: (clickable == .to || clickable == .all)) {
                    clickTo?(toContact)
                }
                    .frame(maxWidth: .infinity)
            }
            arrow()
        }
    }
    
    @ViewBuilder
    func userCard(contact: Contact, showArrow: Bool = false, onClick: (()->())? = nil) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                if let user = contact.user {
                    user.emoji.icon(size: 32)
                }else {
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
        .onTapGesture {
            if showArrow {
                onClick?()
            }
        }
        .padding(16)
        .background(.Theme.BG.bg3)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }
    
    @ViewBuilder
    func arrow() -> some View {
        Image("icon_assets_move_arrow")
            .resizable()
            .frame(width: 32, height: 32)
            .cornerRadius(16)
    }
}


struct MoveFeeView: View {
    var isFree = false
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Move Fee")
                    .font(.inter(size: 12, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
                Spacer()
                Text(feeBalance())
                    .font(.inter(size: 12, weight: .bold))
                    .foregroundStyle(Color.Theme.Text.black8)
            }
            .frame(height: 16)
            Text(feeHint())
                .font(.inter(size: 12, weight: .bold))
                .foregroundStyle(Color.Theme.Text.black6)
                .frame(height: 16)
        }
    }
    
    func feeBalance() -> String {
        return isFree ? "0.00 FLOW" : ("move_fee_cost".localized + " FLOW")
    }

    func feeHint() -> String {
        return isFree ?  "move_fee_hint_free".localized :  "move_fee_hint_cost".localized
    }
}


#Preview {
    Group {
        ContactRelationView(fromContact: Contact(address: "0x123", avatar: nil, contactName: "abc", contactType: .user, domain: nil, id: 1, username: "", walletType: .evm), toContact: Contact(address: "0xabc", avatar: nil, contactName: "123", contactType: .user, domain: nil, id: 1, username: "", walletType: .link))
            .background(Color.Theme.Accent.grey)
        MoveFeeView(isFree: true)
        Divider()
        MoveFeeView(isFree: false)
    }
    
}
