//
//  MenuItem.swift
//  FriendFinder
//
//  Created by Avi on 8/16/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import Foundation
import UIKit

struct MenuItem {
    var name: String
    var icon: UIImage?
    var segueID: String
    
    public init(name: String, segueID: String, icon: UIImage? = nil) {
        self.name = name
        self.segueID = segueID
        self.icon = icon
    }
}
