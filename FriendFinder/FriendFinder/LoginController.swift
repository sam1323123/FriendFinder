//
//  ButtonController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 6/21/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class LoginController: UIViewController {


    @IBOutlet weak var username_textfield: UITextField!
    
    @IBOutlet weak var password_texfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded")
        username_textfield.setBottomBorder()
        password_texfield.setBottomBorder()

        // Do any additional setup after loading the view.
        loadAndSetImageBackground()
    }
    
    private func loadAndSetImageBackground() {
        //create image view
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = #imageLiteral(resourceName: "high-five-sunset")
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        //add it as background current login view
        view.addSubview(backgroundImageView)
        view.sendSubview(toBack: backgroundImageView)
        
        
        // adding NSLayoutConstraints
        let leadingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    @IBAction func goBack(segue: UIStoryboardSegue){
        print("Button pressed")
        if let src = segue.source as? NextViewController {
            print(src.NextLabel.text!)
        }
    }

    
    /*
     Method for initial screen login. Linked to the Login/Enter button in 
     ButtonViewController
     */
    @IBAction func moveFromLoginScreen() {
        
        
        if let user = self.username_textfield.text , let pass = self.password_texfield.text {
            
            //set entered passwords to empty
            if(user == "" || pass == "" || user.rangeOfCharacter(from: CharacterSet.whitespaces) != nil
                || pass.rangeOfCharacter(from: CharacterSet.whitespaces) != nil){
                //if contains whitespace or is empty string
                print("invalid login args")
                return
            }
            self.username_textfield.text = nil
            self.password_texfield.text = nil
            performSegue(withIdentifier: "Login", sender: nil)
            
        }
        
    }
    

}


extension UITextField {
    func setBottomBorder() {
        let border = CALayer()
        let delta = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - delta, width:  self.frame.size.width, height: delta)
        
        border.borderWidth = delta
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        
        set {
           self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue ?? UIColor.black])
        }
    }
}
