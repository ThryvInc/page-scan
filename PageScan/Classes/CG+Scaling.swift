//
//  CG+Scaling.swift
//  PDSLibrary
//
//  Created by Elliot Schrock on 9/22/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation

public extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}

public extension CGSize {
    func scaler() -> (CGPoint) -> CGPoint {
        return { $0.scaled(to: self) }
    }
}

public extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}
