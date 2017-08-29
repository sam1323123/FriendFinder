//
//  NotificationCellTableViewCell.swift
//  FriendFinder
//
//  Created by Samuel Lee on 8/22/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemIcon: UIImageView!
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var arrowLabel: UILabel!
    
    var isExpanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        countLabel.layer.borderColor = UIColor.clear.cgColor //make border transparent
        countLabel.layer.cornerRadius = countLabel.frame.width //makes it into circle
        countLabel.clipsToBounds = true //required for changing to circle
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //ensures formatting is correct after setting properties of the labels like text...
    func recalibrateComponents() {
        print("HEIGHT OF THE COUNTLABeL IS \(countLabel.frame.width)")
        countLabel.layer.cornerRadius = countLabel.frame.width/2  //makes it into circle
        countLabel.clipsToBounds = true

    }

}
