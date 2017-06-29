//
//  BottomBorderTextField.swift
//  FriendFinder
//
//  Created by Avi on 6/29/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class BottomBorderTextField: UITextField {
    
    @IBInspectable var borderColor: UIColor!
    
    @IBInspectable var borderWidth: CGFloat = 1

    @IBInspectable var placeHolderColor: UIColor! {
        get {
            return self.placeHolderColor
        }
        
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue])
        }
    }

    
    override func draw(_ rect: CGRect) {
        let start = CGPoint(x: rect.minX, y: rect.maxY)
        let end = CGPoint(x: rect.maxX, y: rect.maxY)
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        path.lineWidth = borderWidth
        borderColor.setStroke()
        path.stroke()
    }
}
