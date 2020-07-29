//
//  Quadrangle.swift
//  PDSLibrary
//
//  Created by Elliot Schrock on 10/6/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation
import Vision

public struct Quadrangle {
    public static let zero = Quadrangle(topLeft: .zero, topRight: .zero, bottomLeft: .zero, bottomRight: .zero)

    public init(
        topLeft: CGPoint,
        topRight: CGPoint,
        bottomLeft: CGPoint,
        bottomRight: CGPoint
        ) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }

    public var topLeft: CGPoint
    public var topRight: CGPoint
    public var bottomLeft: CGPoint
    public var bottomRight: CGPoint

    public var path: CGPath {
        let path = CGMutablePath()
        path.move(to: topLeft)
        path.addLine(to: topRight)
        path.addLine(to: bottomRight)
        path.addLine(to: bottomLeft)
        path.closeSubpath()
        return path
    }

    public func map(_ transform: (CGPoint) -> CGPoint) -> Quadrangle {
        return Quadrangle(
         topLeft: transform(topLeft),
         topRight: transform(topRight),
         bottomLeft: transform(bottomLeft),
         bottomRight: transform(bottomRight)
        )
    }
 }

public extension VNRectangleObservation {
    func toQuadrangle() -> Quadrangle {
        return Quadrangle(topLeft: topLeft,
                          topRight: topRight,
                          bottomLeft: bottomLeft,
                          bottomRight: bottomRight)
    }
}
