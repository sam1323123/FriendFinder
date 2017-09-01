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
    
    
    var manualConstraints: [NSLayoutConstraint] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        acceptButton.titleLabel?.font = UIFont.fontAwesome(ofSize: acceptButton.titleLabel?.font.pointSize ?? 17.0)
        acceptButton.setTitle(String.fontAwesomeIcon(name: .check), for: UIControlState.normal)
        declineButton.titleLabel?.font = UIFont.fontAwesome(ofSize: declineButton.titleLabel?.font.pointSize ?? 17.0)
        declineButton.setTitle(String.fontAwesomeIcon(name: .close), for: UIControlState.normal)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}



