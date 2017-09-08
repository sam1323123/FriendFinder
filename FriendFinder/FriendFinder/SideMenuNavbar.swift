//
//  sideMenuNavbar.swift
//  FriendFinder
//
//  Created by Samuel Lee on 9/7/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class SideMenuNavbar: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    let defaultWidth = 40.0
    let defaultHeight = 40.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //init code here
        frame.size = CGSize(width: defaultWidth, height: defaultHeight)
    }
    
    func initializeContent(image: UIImage?, title: String) {
        titleLabel.text = title
        iconImageView.image = image
        sizeToFit()
    }
    
    func awakeAndInitialize(image: UIImage?, title: String) {
        awakeFromNib()
        initializeContent(image: image, title: title)
    }

}
