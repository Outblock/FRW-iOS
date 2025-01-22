//
//  DeveloperModeViewModel.swift
//  Flow Wallet
//
//  Created by Selina on 15/9/2022.
//

import Combine
import Flow
import SwiftUI

// MARK: - DeveloperModeViewModel

class DeveloperModeViewModel: ObservableObject {
    // MARK: Lifecycle

    init() {
        if let customWatchAddress = customWatchAddress, !customWatchAddress.isEmpty {
            self.customAddressText = customWatchAddress
        }

        NotificationCenter.default.publisher(for: .watchAddressDidChanged).sink { [weak self] _ in
            guard let self = self else {
                return
            }

            DispatchQueue.main.async {
                self.customWatchAddress = LocalUserDefaults.shared.customWatchAddress
                self.customAddressText = self.customWatchAddress ?? ""
            }
        }.store(in: &cancelable)
    }

    // MARK: Internal

    @Published
    var customWatchAddress: String? = LocalUserDefaults.shared.customWatchAddress
    @Published
    var customAddressText: String = ""
    private(set) var demoAddress: String = "0x01d63aa89238a559"
    private(set) var svgDemoAddress: String = "0x95601dba5c2506eb"

    // MARK: Private

    private var cancelable = Set<AnyCancellable>()
}

extension DeveloperModeViewModel {
    var isCustomAddress: Bool {
        if let address = customWatchAddress, !address.trim().isEmpty {
            return true
        }

        return false
    }

    var isSVGDemoAddress: Bool {
        if let address = customWatchAddress, address == svgDemoAddress {
            return true
        }

        return false
    }

    var isDemoAddress: Bool {
        if let address = customWatchAddress, address == demoAddress {
            return true
        }

        return false
    }

    func changeCustomAddressAction(_ address: String) {
        if address.isEmpty {
            LocalUserDefaults.shared.customWatchAddress = nil
            return
        }

        LocalUserDefaults.shared.customWatchAddress = address
    }
}
