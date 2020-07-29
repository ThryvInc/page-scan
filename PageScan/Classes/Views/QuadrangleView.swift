//
//  QuadrangleView.swift
//  PDSLibrary
//
//  Created by Elliot Schrock on 10/6/19.
//  Copyright © 2019 Project Documents Solutions. All rights reserved.
//

import Foundation

open class QuadrangleView: UIView {
    public var quadrangle: Quadrangle {
        didSet {
            setNeedsDisplay()
        }
    }

    public init(quadrangle: Quadrangle) {
        self.quadrangle = quadrangle
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.addPath(quadrangle.path)

        context?.setStrokeColor(UIColor.orange.withAlphaComponent(0.9).cgColor)
        context?.setFillColor(UIColor.orange.withAlphaComponent(0.3).cgColor)
        context?.drawPath(using: .fillStroke)
    }
}
