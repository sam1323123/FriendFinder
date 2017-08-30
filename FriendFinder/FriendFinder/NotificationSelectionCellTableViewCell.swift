//
//  NotificationSelectionCellTableViewCell.swift
//  FriendFinder
//
//  Created by Samuel Lee on 8/29/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import ExpandableCell

class NotificationSelectionCell: ExpandableCell {
    
    @IBOutlet weak var itemNameLabel: UILabel!
    
    @IBOutlet weak var acceptButton: NotificationSelectionButton!
    
    @IBOutlet weak var declineButton: NotificationSelectionButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
