//
//  Utils.swift
//  FriendFinder
//
//  Created by Avi on 7/15/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import Foundation
import UIKit
import ContactsUI

// utility class containing useful methods
class Utils {
    
    static let gold = UIColor(colorLiteralRed: 212.0/255.0, green: 175.0/255.0, blue: 55.0/255.0, alpha: 1)
    static let orange = UIColor(colorLiteralRed: 255.0/255.0, green: 144.0/255.0, blue: 71.0/255.0, alpha: 1)
    

    //displays alert with given message and text
    static func displayAlert(with controller: UIViewController, title: String, message: String, text: String, callback: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: text, style: .default) {
            (action: UIAlertAction) -> Void in
            if let f = callback {
                f()
            }
        })
        controller.present(alertController, animated: true, completion: completion)
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
    
    static func getVisibleViewController(_ rootViewController: UIViewController? = nil) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
    
}

