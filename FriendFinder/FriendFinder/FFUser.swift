//
//  FFUser.swift
//  FriendFinder
//
//  Created by Avi on 8/13/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

struct FFUser {
    var name: String
    var username: String
    var location: CLLocation?
    var picture: UIImage?
    
    public init(name: String, username: String, location: CLLocation? = nil, picture: UIImage? = nil) {
        self.name = name
        self.username = username
        self.location = location
        self.picture = picture
    }
}
