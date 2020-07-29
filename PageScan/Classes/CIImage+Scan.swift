//
//  CIImage+Scan.swift
//  PDSLibrary
//
//  Created by Elliot Schrock on 9/22/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Vision
import CoreImage

let kCIInputTopLeft = "inputTopLeft"
let kCIInputTopRight = "inputTopRight"
let kCIInputBottomLeft = "inputBottomLeft"
let kCIInputBottomRight = "inputBottomRight"
let kCIInputExtent = "inputExtent"

let kCIPerspectiveCorrection = "CIPerspectiveCorrection"
let kCIColorControls = "CIColorControls"

public extension CIImage {
    func correctImageOrientation(fromOrientation inputOrientation: UIImage.Orientation) -> UIImage? {
        var orientation: UIImage.Orientation? = nil
        
        switch inputOrientation {
        case .down:
            orientation = UIImage.Orientation.left
            
        case .left:
            orientation = UIImage.Orientation.up
            
        case .up:
            orientation = UIImage.Orientation.right
            
        case .right:
            orientation = UIImage.Orientation.down
            
        default:
            orientation = UIImage.Orientation.up
        }
        
        let height = self.extent.size.height
        let width = self.extent.size.width
        var size = CGSize(width: width, height: height)
        var rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        if height < width {
            size = CGSize(width: height, height: width)
            rect = CGRect(x: 0, y: 0, width: height, height: width)
        }
        
        UIGraphicsBeginImageContext(size)
        
        var image: UIImage? = UIImage(ciImage: self, scale: 1, orientation: orientation!)
        image?.draw(in: rect)
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func filterImageUsingContrastFilter() -> CIImage? {
        guard let imageFiltered: CIFilter = CIFilter(name: kCIColorControls, withInputParameters:
            [
                kCIInputImageKey: self,
                kCIInputContrastKey: 1.4,
                kCIInputSaturationKey: 0.0
            ]) else { return nil }
        
        return imageFiltered.outputImage
    }
    
    func perspectiveCorrectionParams(fromRectangle rectangle: Quadrangle) -> [String: CIVector] {
        return [
            kCIInputTopLeft: CIVector(cgPoint: rectangle.topLeft),
            kCIInputTopRight: CIVector(cgPoint: rectangle.topRight),
            kCIInputBottomLeft: CIVector(cgPoint: rectangle.bottomLeft),
            kCIInputBottomRight: CIVector(cgPoint: rectangle.bottomRight)
        ]
    }
    
    // MARK: - Crop Methods
    
    func cropWithColorContrast(from detectedRectangle: VNRectangleObservation) -> UIImage? {
        guard var image = self.filterImageUsingContrastFilter() else { return UIImage() }
        let boundingBox = detectedRectangle.boundingBox.scaled(to: self.extent.size)
        
        let quadrangle = detectedRectangle.toQuadrangle().map(self.extent.size.scaler())
        
        image = image.cropped(to: boundingBox)
            .applyingFilter(kCIPerspectiveCorrection, parameters: perspectiveCorrectionParams(fromRectangle: quadrangle))
        
        return image.correctImageOrientation(fromOrientation: .up)
    }
}
