//
//  sideMenuNavbar.swift
//  FriendFinder
//
//  Created by Samuel Lee on 9/7/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class SideMenuNavbar: UIView {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
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
    
    func initializeContent(image: UIImage?, name: String, username: String) {
        usernameLabel.text = username
        iconImageView.image = image
        nameLabel.text = name
        sizeToFit()
    }
    
    func awakeAndInitialize(image: UIImage?, name: String, username: String) {
        awakeFromNib()
        initializeContent(image: image, name: name, username: username)
    }

}
