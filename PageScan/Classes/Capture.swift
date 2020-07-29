//
//  Capture.swift
//  PDSLibrary
//
//  Created by Soroush Khanlou on 9/5/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import AVFoundation
import UIKit
import CoreImage
import Vision

private protocol Configurable {}
extension Configurable {
    func configure(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}
extension AVCaptureSession: Configurable {}

open class Capture {
    public let session = AVCaptureSession().configure { $0.sessionPreset = .photo }
    public let output = AVCapturePhotoOutput()
    public var capturedImage: UIImage?
    public var videoConnection: AVCaptureConnection? {
        return output
            .connections
            .compactMap({ $0 })
            .first(where: { connection in
                return connection.inputPorts.contains(where: { $0.mediaType == .video })
            })
    }

    open func setUp(with cameraView: CameraPreview?) {
        cameraView?.session = session
        session.addOutput(output)

        authorizeThenActivate()
    }

    open func activate() {
        if let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device) {
            self.session.addInput(input)
        }
    }

    open func authorizeThenActivate() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
            if granted {
                self.activate()
            }
        })
    }

    open func cameraAllowed() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized
    }

    open func startRunning() {
        session.startRunning()
    }

    open func stopRunning() {
        session.stopRunning()
    }

    open func capture(observation: VNRectangleObservation, completion: @escaping (UIImage) -> Void) {
        return output.capture(completion: { photo in

            guard let imageData = photo.fileDataRepresentation(),
                let image = UIImage(data: imageData),
                let ciImage = CIImage.init(image: image) else { return }
            if let cropped = ciImage.cropWithColorContrast(from: observation) {
                DispatchQueue.main.async(execute: {
                    self.capturedImage = cropped
                    completion(cropped)
                })
            }
        })
    }

    open var hasCapturedImage: Bool {
        return capturedImage != nil
    }

    open func clear() {
        capturedImage = nil
    }
}

open class CaptureTrampoline: NSObject, AVCapturePhotoCaptureDelegate {
    public var handler: (AVCapturePhoto) -> Void = { _ in }

    open func capture(with photoOutput: AVCapturePhotoOutput, completion: @escaping (AVCapturePhoto) -> Void) {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoOutput.capturePhoto(with: settings, delegate: self)

        // capture self in a completion block so that the CaptureTrampoline doesn't get deallocated while the capture process is happening
        handler = { photo in
            _ = self
            completion(photo)
        }
    }

    open func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            fatalError(error.localizedDescription)
        } else {
            handler(photo)
        }
    }
}

public extension AVCapturePhotoOutput {
    func capture(completion: @escaping (AVCapturePhoto) -> Void) {
        return CaptureTrampoline().capture(with: self, completion: completion)
    }
}
