//
//  CreateProfileWaitingViewModel.swift
//  FRW
//
//  Created by cat on 2024/6/5.
//

import Combine
import Flow
import Foundation
import SwiftUI
import SwiftUIPager

class CreateProfileWaitingViewModel: ObservableObject {
    // MARK: Lifecycle

    deinit {
        EventTrack.Account.createdTimeEnd()
    }


    init(txId: String, callback: @escaping (Bool) -> Void) {
        self.txId = Flow.ID(hex: txId)
        self.callback = callback

        WalletManager.shared.$walletInfo
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .map { $0 }
            .sink { [weak self] walletInfo in
                let isEmptyBlockChain = walletInfo?.currentNetworkWalletModel?
                    .isEmptyBlockChain ?? true
                if !isEmptyBlockChain {
                    self?.updateWalletInfo()
                    self?.createFinished = true
                    EventTrack.Account.createdTimeEnd()
                }

            }.store(in: &cancellableSet)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: DispatchWorkItem(block: {
            self.startTimer()
        }))
        EventTrack.Account.createdTimeStart()
    }

    // MARK: Internal

    @Published
    var animationPhase: AnimationPhase = .initial
    @Published
    var page: Page = .first()
    @Published
    var createFinished = false
    @Published
    var currentPage: Int = 0

    var txId = Flow.ID(hex: "")
    var callback: (Bool) -> Void

    func onPageIndexChangeAction(_ index: Int) {
        withAnimation(.default) {
            currentPage = index
        }
    }

    func onPageDrag(_ isDraging: Bool) {
        if isDraging {
            stopTimer()
        } else {
            startTimer()
        }
    }

    func onConfirm() {
        HUD.success(title: "create_user_success".localized)
        stopTimer()
        callback(true)
        ConfettiManager.show()
    }

    // MARK: Private

    private var timer: Timer?

    private var cancellableSet = Set<AnyCancellable>()

    @objc
    private func onHolderStatusChanged(noti: Notification) {
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

    private func startTimer() {
        stopTimer()
        let timer = Timer.scheduledTimer(
            timeInterval: 10,
            target: self,
            selector: #selector(onTimer),
            userInfo: nil,
            repeats: true
        )
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func stopTimer() {
        if let current = timer {
            current.invalidate()
            timer = nil
        }
    }

    @objc
    private func onTimer() {
        if page.index == 2 {
            page.update(.moveToFirst)
        } else {
            withAnimation {
                page.update(.next)
            }
        }
        currentPage = page.index
    }

    private func updateWalletInfo() {
        guard let uid = UserManager.shared.activatedUID, let address = WalletManager.shared.getPrimaryWalletAddress() else {
            return
        }
        LocalUserDefaults.shared.updateSEUser(by: uid, address: address)
    }
}
