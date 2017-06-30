//
//  ButtonController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 6/21/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {

    var backgroundImageView : UIImageView = UIImageView()
    
    @IBOutlet weak var username_textfield: BottomBorderTextField!
    
    @IBOutlet weak var password_textfield: BottomBorderTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded")

        // do any additional setup after loading the view.
        loadAndSetImageBackground()
    }
    
    //sets and loads background
    private func loadAndSetImageBackground() {
        //create image view
        backgroundImageView.bounds = UIScreen.main.bounds
        backgroundImageView.contentMode = .redraw
        backgroundImageView.image = getOrientedImage(basedOn: UIApplication.shared.statusBarOrientation)
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
    
     //changes background on rotation
     override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         coordinator.animate(alongsideTransition: { [weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
        let orientation = UIApplication.shared.statusBarOrientation
        self?.backgroundImageView.image = self?.getOrientedImage(basedOn: orientation)
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            print("rotation completed")
        })
    }

    //decides background based on orientation
    func getOrientedImage(basedOn orientation : UIInterfaceOrientation) -> UIImage {
        return orientation.isPortrait ? #imageLiteral(resourceName: "high-five-sunset-portrait") : #imageLiteral(resourceName: "high-five-sunset-landscape")
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
    @IBAction func signupPressed() {
        
        if let username = username_textfield.text , let pw = password_texfield.text {
            if (user == "" || pw == "" || user.rangeOfCharacter(from: CharacterSet.whitespaces) != nil
                || pw.rangeOfCharacter(from: CharacterSet.whitespaces) != nil){
                    //if contains whitespace or is empty string
                let alertController = UIAlertController(title: "No spaces allowed!", message: "Please remove all spaces from input.", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("OK pressed")
                })
                present(alertController, animated: true)
            }
            
            if (username.isNumeric()) {
                
            }
            //validate username
            if (!username.validateEmail()) {
                let alertController = UIAlertController(title: "Email address is invalid!", message: "Please use a valid email address.", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("OK pressed")
                })
                present(alertController, animated: true)
            }
            
            //validate password
            if (!pw.validatePassword()) {
                let alertController = UIAlertController(title: "Password is invalid!", message: "Password must be alphanumeric, contain $,@,$,#,!,%,*,?,& or . and at least 8 characters long.", preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("OK pressed")
                })
                present(alertController, animated: true)
            }
            
            emailSignup(username, pw)
            

        
            //set entered passwords to empty
            self.username_textfield.text = nil
            self.password_textfield.text = nil
            
            performSegue(withIdentifier: "Signup", sender: nil)
            
        }
    }
    
    
    func emailSignup(_ email_address: String, _ pw: String) {
        Auth.auth().createUser(withEmail: email_address, password: pw) { (user, error) in
            
        }
    }

}

extension String {
    
    func validateEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    
    
    func validatePassword() -> Bool{
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[$@$#!%*?&.])[A-Za-z\\d$@$#!%*?&.]{8,}")
        return passwordPredicate.evaluate(with: self)
    }
    
    func isNumeric() -> Bool {
        return Int(self) != nil
    }
}
