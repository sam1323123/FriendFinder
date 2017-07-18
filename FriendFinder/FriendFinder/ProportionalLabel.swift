//
//  ProportionalLabel.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/18/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

// Use this if want to size proportionally within stack view


class ProportionalLabel: UILabel{
    
    @IBInspectable
    var heightForStackView:  Double = 1.0
    
    var widthForStackView: Double = 1.0

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: widthForStackView, height: heightForStackView)
    }

    
}
