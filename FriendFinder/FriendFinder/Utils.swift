//
//  Utils.swift
//  FriendFinder
//
//  Created by Avi on 7/15/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import Foundation
import UIKit

// utility class containing useful methods
class Utils {
    
    static let gold = UIColor(colorLiteralRed: 212.0/255.0, green: 175.0/255.0, blue: 55.0/255.0, alpha: 1)
    
    //displays alert with given message and text
    static func displayAlert(with controller: UIViewController, title: String, message: String, text: String, callback: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: text, style: .default) {
            (action: UIAlertAction) -> Void in
            if let f = callback {
                f()
            }
        })
        controller.present(alertController, animated: true)
    }
    
    //displays alert with given message and text
    static func displayAlertWithCancel(with controller: UIViewController, title: String, message: String, text: String, callback: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: text, style: .default) {
            (action: UIAlertAction) -> Void in
            if let f = callback {
                f()
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        controller.present(alertController, animated: true)
    }
    
}

