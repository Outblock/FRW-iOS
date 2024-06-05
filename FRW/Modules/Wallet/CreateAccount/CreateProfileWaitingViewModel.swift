//
//  CreateProfileWaitingViewModel.swift
//  FRW
//
//  Created by cat on 2024/6/5.
//

import Foundation
import Flow

class CreateProfileWaitingViewModel: ObservableObject {
    
    @Published var animationPhase: AnimationPhase = .initial
    
    var txId: Flow.ID = Flow.ID(hex: "")
    var callback:(Bool)->()
    
    init(txId: String, callback:@escaping (Bool)->()) {
        self.txId = Flow.ID(hex: txId)
        self.callback = callback
        NotificationCenter.default.addObserver(self, selector: #selector(onHolderStatusChanged(noti:)), name: .transactionStatusDidChanged, object: nil)

    }
    
    @objc private func onHolderStatusChanged(noti: Notification) {
        guard let holder = noti.object as? TransactionManager.TransactionHolder,
              holder.transactionId.hex == txId.hex
        else {
            return
        }
        guard let current = AnimationPhase(rawValue: holder.flowStatus.rawValue) else {
            return
        }
        
        animationPhase = current
    }
    
}
