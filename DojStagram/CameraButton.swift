//
//  CameraButton.swift
//  DojStagram
//
//  Created by Daniel Thompson on 3/17/17.
//  Copyright © 2017 Daniel Thompson. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CameraButton: UIButton {
    
    @IBInspectable var lineWidth:CGFloat = 2
    @IBInspectable var fillColor:UIColor = UIColor.red
    @IBInspectable var strokeColor:UIColor = UIColor.blue
    
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)
        let path = UIBezierPath(ovalIn: insetRect)
        path.lineWidth = lineWidth
        
        fillColor.setFill()
        path.fill()
        
        strokeColor.setStroke()
        path.stroke()
    }
    
    
}
