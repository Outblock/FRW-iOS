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

import AVKit
import Foundation
import UIKit

public class SPQRCode {
    // MARK: Public

    public static func scanning(
        detect: ((SPQRCodeData?, SPQRCameraController) -> SPQRCodeData?)? = nil,
        handled: SPQRCodeCallback?,
        click: SPQRCodeCallback? = nil,
        on controller: UIViewController
    ) {
        if deviceIsValid() == false {
            HUD.error(title: "camera_is_invalid".localized)
            return
        }

        let qrController = SPQRCameraController()
        if let detect = detect {
            qrController.detectQRCodeData = detect
        }
        qrController.handledQRCodeData = handled
        qrController.clickQRCodeData = click
        qrController.modalPresentationStyle = .fullScreen
        controller.present(qrController)
    }

    // MARK: Private

    private class func deviceIsValid() -> Bool {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {
            return false
        }

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return false
        }

        return true
    }
}
