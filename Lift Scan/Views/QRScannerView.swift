//
//  QRScannerView.swift
//  Lift Scan
//
//  Created by Ethan McRae on 8/1/23.
//

import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    var onFound: (String) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self, onFound: onFound)
    }
    
    typealias UIViewControllerType = UIViewController

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView
        var onFound: (String) -> Void

        init(_ parent: QRScannerView, onFound: @escaping (String) -> Void) {
            self.parent = parent
            self.onFound = onFound
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                onFound(stringValue)
            }
        }
        
        @objc func cancel() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        
        // Create a cancel button
        let button = UIButton(frame: CGRect(x: 20, y: 20, width: 80, height: 40))
        button.setTitle("Cancel", for: .normal)
        button.backgroundColor = UIColor.systemRed
        button.layer.cornerRadius = 5
        button.addTarget(context.coordinator, action: #selector(Coordinator.cancel), for: .touchUpInside)

        // Create a semi-transparent layer under the cancel button
        let backgroundView = UIView(frame: CGRect(x: 10, y: 10, width: 100, height: 60))
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.layer.cornerRadius = 15
        
        viewController.view.addSubview(backgroundView)
        viewController.view.addSubview(button)

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
