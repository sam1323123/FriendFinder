//
//  MenuViewCell.swift
//  FriendFinder
//
//  Created by Avi on 8/14/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class MenuViewCell: UITableViewCell {
    
    @IBOutlet weak var itemIcon: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
