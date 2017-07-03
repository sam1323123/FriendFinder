//
//  ButtonController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 6/21/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseAuth
import FacebookLogin
import FacebookCore

class LoginController: UIViewController, LoginButtonDelegate {

    var backgroundImageView : UIImageView = UIImageView()
    
    @IBOutlet weak var username_textfield: BottomBorderTextField!
    
    @IBOutlet weak var password_textfield: BottomBorderTextField!
    
    //needed to align facebook login
    @IBOutlet weak var mainStackView: UIStackView!
    
    
    //dictionary mapping errors to error messages
    let errorDict : [AuthErrorCode:(String, String)] = FirebaseErrors.errors

    
    //initializes what will be viewed
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded")
        // do any additional setup after loading the view.
        loadAndSetImageBackground()
        initializeFacebookLogin()
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
    
    //login with facebook method
     func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        print("HEYYYYY")
        switch result {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("Cancelled")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged In")
                if let accessToken = AccessToken.current {
                    // User is logged in, use 'accessToken' here.
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
                    Auth.auth().signIn(with: credential) { [weak self](user, error) in
                        self?.handleSignInError(error: error)
                }
            }
        }
    }
    
    //facebook logout method
     func loginButtonDidLogOut(_ loginButton: LoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("Logged Out")
    }
    
    
    private func initializeFacebookLogin() {
        let loginButton = LoginButton(readPermissions: [  .publicProfile, .email, .userFriends ])
        
        //initial position and size
        loginButton.frame = CGRect(x: self.mainStackView.bounds.minX, y: self.mainStackView.bounds.maxY,
                                   width: self.mainStackView.bounds.width, height: self.password_textfield.bounds.height)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        
        /*
        add constraints to login here. Currently made to sit below main stack view and be of same width
        of stackVew and same height as the username recet 
         */
        let leadingConstraint = NSLayoutConstraint(item: loginButton, attribute: .leading, relatedBy: .equal, toItem: self.mainStackView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: loginButton , attribute: .top, relatedBy: .equal, toItem: self.mainStackView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .equal, toItem: self.password_textfield, attribute: .height, multiplier: 1.0, constant: 0.0)
        let widthConstraint  = NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: self.mainStackView, attribute: .width, multiplier: 1.0, constant: 0.0)

        
        NSLayoutConstraint.activate([leadingConstraint, topConstraint, heightConstraint, widthConstraint])
        
        
    
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
    
    
    //TODO: back button remove?
    @IBAction func goBack(segue: UIStoryboardSegue){
        print("Button pressed")
        if let src = segue.source as? NextViewController {
            print(src.NextLabel.text!)
        }
    }


    //signup button handler
    @IBAction func signupPressed() {
        if let username = username_textfield.text, let pw = password_textfield.text {
            if (username == "" || pw == "" || username.hasWhitespace() || pw.hasWhitespace()){
                //if contains whitespace or is empty string
                displayAlert(title: "No spaces allowed!", message: "Please remove all spaces from input.", text: "OK")
                return
            }
            
            if (username.isNumeric()) {
                
            }
            
            //validate username
            if (!username.validateEmail()) {
                displayAlert(title: "Email address is invalid!", message: "Please use a valid email address.", text: "OK")
                return
            }
            
            emailSignup(username, pw)
        }
    }

    //signup by mail method
    private func emailSignup(_ email_address: String, _ pw: String) {
        
        Auth.auth().createUser(withEmail: email_address, password: pw) { [weak self] (user, error) in
            
            if let val = error?._code {
                if let code = AuthErrorCode(rawValue: val) {
                    if let tuple = self?.errorDict[code] {
                        let title = tuple.0
                        let message = tuple.1
                        self?.displayAlert(title: title, message: message, text: "OK")
                    }
                }
                else {
                    self?.displayAlert(title: "Unexpected Error", message: "Please try again later.", text: "OK")
                }
            }
            else {
                //set entered fields to empty
                self?.username_textfield.text = nil
                self?.password_textfield.text = nil
                user?.sendEmailVerification(completion: {[weak self] error in
                    if let val = error?._code {
                        if let code = AuthErrorCode(rawValue: val) {
                            if let tuple = self?.errorDict[code] {
                                let title = tuple.0
                                let message = tuple.1
                                self?.displayAlert(title: title, message: message, text: "OK")
                            }
                        }
                        else {
                            self?.displayAlert(title: "Unexpected Error", message: "Please try again later.", text: "OK")
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self?.displayAlert(title: "Validation email sent!", message: "Please validate the entered email.", text: "OK") {
                                [weak self] in
                                self?.performSegue(withIdentifier: "Signup", sender: nil)
                            }
                        }
                    }
                })
            }
            print(user?.email! ?? "No email!")
        }
    }
    
    //login button handler
    @IBAction private func loginPressed(_ sender: UIButton) {
        
        if let username = self.username_textfield.text , let pw = self.password_textfield.text {
            
            if(username == "" || pw == "" || username.hasWhitespace() || pw.hasWhitespace()) {
                displayAlert(title: "No spaces allowed!", message: "Please remove all spaces from input.", text: "OK")
                self.username_textfield.text = ""
                self.password_textfield.text = ""
                return
            }
            
            //for debugging purposes
            if(username == "admin" && pw == "password") {
                performSegue(withIdentifier: "Map" , sender: nil)
                return
            }

            emailLogin(username: username, pw: pw)
        }
    }
    
    //login with mail method
    private func emailLogin(username: String, pw: String) {
        Auth.auth().signIn(withEmail: username, password: pw) {[weak self] (user, error) in
            if let _ = user {
                // might need to prepare segue later
                self?.performSegue(withIdentifier: "Login" , sender: nil)
            }
                
            else {
                self?.handleSignInError(error: error)
            }
        }
    }

    //helper to handle sign in errors
    private func handleSignInError(error: Error?) {
        if let code = AuthErrorCode(rawValue: error!._code) {
            if let tuple = errorDict[code] {
                let title = tuple.0
                let message = tuple.1
                displayAlert(title: title, message: message, text: "OK")
            }
            else {
                displayAlert(title: "Unexpected Error in Login" , message: "Pleas try again later", text: "OK")
            }
        }

    }

    //displays alert with given message and text
    func displayAlert(title: String, message: String, text: String, callback: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: text, style: .default) {
            (action: UIAlertAction) -> Void in
            if let f = callback {
                    f()
            }
        })
        present(alertController, animated: true)
    }
    
    
    

}

//useful extension to String
extension String {
    
    func validateEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: self)
    }
    
    func isNumeric() -> Bool {
        return Int(self) != nil
    }
    
    func hasWhitespace() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.whitespaces) != nil
    }
}
