// The MIT License (MIT)
// Copyright © 2022 Sparrow Code (hello@sparrowcode.io)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit

public enum SPQRCodeData {
    case url(URL)
    case text(String)
    case ethWallet(String)
    case flowWallet(String)
    case walletConnect(String)

    // MARK: Internal

    var prefix: String {
        switch self {
        case .url:
            return Texts.qr_code_data_url_prefix
        case .text:
            return Texts.qr_code_data_text_prefix
        case .ethWallet:
            return Texts.qr_code_data_eth_wallet_prefix
        case .flowWallet:
            return Texts.qr_code_data_flow_wallet_prefix
        case .walletConnect:
            return Texts.qr_code_data_wallet_connect_prefix
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .url:
            return Images.detail_safari()
        case .text:
            return Images.detail_eth_wallet()
        case .ethWallet:
            return Images.detail_eth_wallet()
        case .flowWallet:
            return Images.detail_flow_wallet()
        case .walletConnect:
            return Images.detail_flow_wallet()
        }
    }
}
