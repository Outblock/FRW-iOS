//
//  PrivateKeyLoginViewModel.swift
//  FRW
//
//  Created by cat on 2024/8/19.
//

import Foundation

class PrivateKeyLoginViewModel: ObservableObject {
    @Published var key: String = ""
    @Published var address: String = ""
    @Published var buttonState: VPrimaryButtonState = .disabled

}
