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

import UIKit
import SparrowKit
import AVKit
import NativeUIKit
import SwiftUI
import SnapKit

public typealias SPQRCodeCallback = ((SPQRCodeData, SPQRCameraController)-> Void)

open class SPQRCameraController: SPController {
    
    open var detectQRCodeData: ((SPQRCodeData, SPQRCameraController)->SPQRCodeData?) = { data, _ in return data }
    open var handledQRCodeData: SPQRCodeCallback? = nil
    open var clickQRCodeData: SPQRCodeCallback? = nil

    internal var updateTimer: Timer?
    internal lazy var captureSession: AVCaptureSession = makeCaptureSession()
    internal var qrCodeData: SPQRCodeData? {
        didSet {
            self.updateInterface()
            self.didTapHandledButton()
        }
    }
    
    // MARK: - Views
    
    internal let frameLayer = SPQRFrameLayer()
    internal let detailView = SPQRDetailButton()
    internal lazy var previewLayer = makeVideoPreviewLayer()
    
    public override init() {
        super.init()
        modalPresentationStyle = .fullScreen
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        view.layoutMargins = .init(horizontal: 20, vertical: .zero)
        view.layer.addSublayer(previewLayer)
        view.layer.addSublayer(frameLayer)
        captureSession.startRunning()
        
        detailView.addTarget(self, action: #selector(didTapDetailButtonClick), for: .touchUpInside)
        view.addSubview(detailView)
        
        addBackButton()
        updateInterface()
    }
    
    func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Actions
    
    @objc func didTapHandledButton() {
        guard let data = qrCodeData else { return }
        handledQRCodeData?(data, self)
    }
    
    @objc func didTapCancelButton() {
        dismissAnimated()
    }
    
    @objc private func didTapDetailButtonClick() {
        guard let data = qrCodeData else { return }
        clickQRCodeData?(data, self)
    }
    
    // MARK: - Layout
    
    private func addBackButton() {
        let image = UIImage(systemName: "arrow.backward")
        let backButton = UIButton(type: .custom)
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        backButton.tintColor = .white
        backButton.sizeToFit()
        view.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.left.equalTo(0)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer.frame = .init(
            x: .zero, y: .zero,
            width: view.layer.bounds.width,
            height: view.layer.bounds.height
        )
    }

    // MARK: - Internal
    
    internal func updateInterface() {
        let duration: TimeInterval = 0.22
        if qrCodeData != nil {
            detailView.isHidden = false
            if case .flowWallet(_) = qrCodeData {
                detailView.applyDefaultAppearance(with: .init(content: .white, background: UIColor(hex: "#00EF8B")))
                frameLayer.strokeColor = UIColor(hex: "#00EF8B").cgColor
            }
            UIView.animate(withDuration: duration, delay: .zero, options: .curveEaseInOut, animations: {
                self.detailView.transform = .identity
                self.detailView.alpha = 1
            })
        } else {
            UIView.animate(withDuration: duration, delay: .zero, options: .curveEaseInOut, animations: {
                self.detailView.transform = .init(scale: 0.9)
                self.detailView.alpha = .zero
            }, completion: { _ in
                self.detailView.isHidden = true
            })
        }
    }
    
    internal static let supportedCodeTypes = [
        AVMetadataObject.ObjectType.aztec,
        AVMetadataObject.ObjectType.qr
    ]
    
    internal func makeVideoPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        return videoPreviewLayer
    }
    
    internal func makeCaptureSession() -> AVCaptureSession {
        let captureSession = AVCaptureSession()
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { fatalError() }
        guard let input = try? AVCaptureDeviceInput(device: device) else { fatalError() }
        captureSession.addInput(input)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = Self.supportedCodeTypes
        return captureSession
    }
}

