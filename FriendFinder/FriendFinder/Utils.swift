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
import FirebaseStorage
import FirebaseDatabase

infix operator ||=
func ||=(lhs: inout Bool, rhs: Bool) { lhs = (lhs || rhs) }


// utility class containing useful methods
class Utils {
    
    static let loginStartupTag = 100
    static let imageViewFillerTag = 200
    
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
    static func displayAlertWithCancel(with controller: UIViewController, title: String, message: String, text: String, style: UIAlertActionStyle? = nil, callback: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: text, style: style ?? .default) {
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
    
    static func displayFiller(for emptyView: UIView, width: CGFloat? = nil, height: CGFloat? = nil, center: CGPoint? = nil) {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "labelled_sad"))
        let superWidth, superHeight: CGFloat
        superWidth = (width != nil) ? width!/2 : emptyView.frame.width/2
        superHeight = (height != nil) ? height!/2 : emptyView.frame.height/2
        let dimension = min(superWidth, superHeight)
        let originX = emptyView.center.x - dimension
        let originY = emptyView.center.y - dimension
        let center = center ?? emptyView.center
        let frame = CGRect(x: originX, y: originY, width: dimension, height: dimension)
        imageView.tag = Utils.imageViewFillerTag
        imageView.frame = frame
        imageView.center = center 
        emptyView.addSubview(imageView)
        emptyView.bringSubview(toFront: imageView)
    }
    
    
}

// custom colors
extension UIColor {
    
    static let gold = UIColor(colorLiteralRed: 212.0/255.0, green: 175.0/255.0, blue: 55.0/255.0, alpha: 1)
    static let orange = UIColor(colorLiteralRed: 255.0/255.0, green: 144.0/255.0, blue: 71.0/255.0, alpha: 1)
    static let teal = UIColor(colorLiteralRed: 56/255.0, green: 114.0/255.0, blue: 108.0/255.0, alpha: 1)
    static let lightTeal = UIColor(colorLiteralRed: 79/255.0, green: 162.0/255.0, blue: 154.0/255.0, alpha: 1)
    
}

extension UIFont {
    
    var isBold: Bool {
        return fontDescriptor.symbolicTraits.contains(.traitBold)
    }
    
    func setBold() -> UIFont {
        if isBold {
            return self
        } else {
            var symTraits = fontDescriptor.symbolicTraits
            symTraits.insert([.traitBold])
            let newDescriptor = fontDescriptor.withSymbolicTraits(symTraits)
            return UIFont(descriptor: newDescriptor!, size: 0)
        }
    }
}

