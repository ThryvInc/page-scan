//
//  CameraView.swift
//  PDSLibrary
//
//  Created by Soroush Khanlou on 9/5/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import AVFoundation
import UIKit

open class CameraPreview: UIView {
    open var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let videoPreviewLayer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("the class of the layer should always be AVCaptureVideoPreviewLayer")
        }
        return videoPreviewLayer
    }
    open var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.session = newValue
        }
    }

    open override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
