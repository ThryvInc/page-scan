//
//  AppleRectangleDetector.swift
//  PDSLibrary
//
//  Created by Elliot Schrock on 10/6/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation
import AVFoundation
import Vision
import ReactiveSwift

// This type's interface can also be fulfilled by OpenCV, in case we want to drop the requirements for the app down to iOS 11
open class AppleRectangleDetector: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let visionSequenceHandler = VNSequenceRequestHandler()

    public var referenceFrameConverter: (CGPoint) -> CGPoint = { $0 }

    public let rectangleObservation = MutableProperty<VNRectangleObservation?>(nil)
    public let referenceFrameRectangles = MutableProperty(Quadrangle.zero)

    open func makeOutput() -> AVCaptureVideoDataOutput {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        return videoOutput
    }

    open func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectRectanglesRequest(completionHandler: { request, error in
            DispatchQueue.main.async {
                guard let rectangle = request.results?.first as? VNRectangleObservation else {
                    self.referenceFrameRectangles.value = .zero
                    self.rectangleObservation.value = nil
                    return
                }

                self.rectangleObservation.value = rectangle
                self.referenceFrameRectangles.value = rectangle.toQuadrangle().map(self.referenceFrameConverter)
            }
        })

        request.minimumSize = 0.3

        try? self.visionSequenceHandler.perform([request], on: pixelBuffer)
    }
    
    open func rect(in image: UIImage, _ completion: @escaping (VNRectangleObservation?) -> Void) {
        let request = VNDetectRectanglesRequest(completionHandler: { request, error in
            DispatchQueue.main.async {
                guard let rectangle = request.results?.first as? VNRectangleObservation else {
                    completion(nil)
                    return
                }

                completion(rectangle)
            }
        })

        request.minimumSize = 0.3

        if let cgImage = image.cgImage {
            try? self.visionSequenceHandler.perform([request], on: cgImage)
        }
    }
}
