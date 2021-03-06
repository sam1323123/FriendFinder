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
import FBSDKCoreKit
import GoogleSignIn
import FirebaseDatabase


class LoginController: UIViewController {

    var backgroundImageView : UIImageView = UIImageView()
    
    @IBOutlet weak var username_textfield: BottomBorderTextField!
    
    @IBOutlet weak var password_textfield: BottomBorderTextField!
    
    //needed to align facebook login
    @IBOutlet weak var mainStackView: UIStackView!
    
    var isLargeScreen: Bool?
    
    var isBackPressed: Bool = false

    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    
    //dictionary mapping errors to error messages
    fileprivate let errorDict : [AuthErrorCode:(String, String)] = Errors.firebaseErrors

    
    //initializes what will be viewed
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View loaded")
        isLargeScreen = ((view.traitCollection.horizontalSizeClass == .regular)
            && (view.traitCollection.verticalSizeClass == .regular))
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        loadAndSetImageBackground()
        let fbButton = initializeFacebookLogin()
        createCustomGoogleButton(below: fbButton)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (Auth.auth().currentUser != nil && !isBackPressed) {
            performSegue(withIdentifier: "Login" , sender: nil)
        }
        else {
            spinner.stopAnimating()
            if let viewWithTag = view.viewWithTag(Utils.loginStartupTag) {
                viewWithTag.removeFromSuperview()
            }
        }
    
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let view = UIView(frame: self.view.frame)
        view.tag = Utils.loginStartupTag
        UIGraphicsBeginImageContext(self.view.frame.size)
        #imageLiteral(resourceName: "high-five-sunset-portrait").draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)
        self.view.addSubview(view)
        self.view.bringSubview(toFront: view)
        spinner.center = view.center
        view.addSubview(spinner)
        view.bringSubview(toFront: spinner)
        spinner.startAnimating()

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
    
    //highlights button
    func highlightButton(sender: UIButton) {
        sender.backgroundColor = .lightGray
    
    }
    
    //removes highlight
    func unhighlightButton(sender: UIButton) {
        sender.backgroundColor = .white
    }
    
}


//extension for facebook login code
extension LoginController: LoginButtonDelegate {
    

    //initializes facebook button and callback
    fileprivate func initializeFacebookLogin() -> UIView {
        let loginButton = LoginButton(readPermissions: [  .publicProfile, .email, .userFriends ])
        
        loginButton.delegate = self
        //initial position and size
        loginButton.frame = CGRect(x: self.mainStackView.bounds.minX, y: self.mainStackView.bounds.maxY,
                                   width: self.mainStackView.bounds.width, height: self.password_textfield.bounds.height)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        view.addSubview(loginButton)
        
        
        /*
         add constraints to login here. Currently made to sit below main stack view and be of same width
         of stackView and same height as the username rect
         */
        let leadingConstraint = NSLayoutConstraint(item: loginButton, attribute: .leading, relatedBy: .equal, toItem: self.mainStackView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: loginButton , attribute: .top, relatedBy: .equal, toItem: self.mainStackView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: loginButton, attribute: .height, relatedBy: .equal, toItem: self.password_textfield, attribute: .height, multiplier: 1.0, constant: 0.0)
        let widthConstraint  = NSLayoutConstraint(item: loginButton, attribute: .width, relatedBy: .equal, toItem: self.mainStackView, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        
        NSLayoutConstraint.activate([leadingConstraint, topConstraint, heightConstraint, widthConstraint])
        
        return loginButton
        
    }
    
    //login with facebook
     func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
        case .failed(let error):
            print("FB Error")
            print(error)
        case .cancelled:
            print("Cancelled")
        case .success(let grantedPermissions, let declinedPermissions, let accessToken):
            print("Logged In")
            // User is logged in, use 'accessToken' here.
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
            Auth.auth().signIn(with: credential) { [weak self] (user, error) in
                self?.login(user: user, error: error)
            }
        }
    }
    
    //facebook logout
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("Logged Out")
    }
    
}

extension LoginController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    //create custom google button
    func createCustomGoogleButton(below: UIView) -> UIButton {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.mainStackView.frame.minX,
                              y: below.frame.maxY,
                              width: self.mainStackView.frame.width,
                              height: self.password_textfield.frame.height)
        
        //set logo
        button.setImage(#imageLiteral(resourceName: "google_background"), for: .normal)
        
        //title formatting
        button.setTitle("Sign in with Google", for: .normal)
        button.titleLabel!.font = UIFont(name: "Roboto-Medium", size: 14.0)
        button.titleLabel!.adjustsFontSizeToFitWidth = true
        button.titleLabel!.adjustsFontForContentSizeCategory = true
        button.titleLabel!.numberOfLines = 1
        button.titleLabel!.textAlignment = .center
        button.setTitleColor(.darkGray, for: .normal)
        
        
        //set borders and spacing
        button.contentEdgeInsets = UIEdgeInsetsMake(2.0, 5.0, 2.0, 5.0)
        let availableSpace = UIEdgeInsetsInsetRect(button.bounds, button.contentEdgeInsets)
        let availableWidth = availableSpace.width - button.imageEdgeInsets.right - button.imageView!.frame.width - button.titleLabel!.frame.width
        let availableHeight = availableSpace.height - button.titleLabel!.frame.height
        
        //adjust based on screen size
        let scaleFactor: CGFloat =  isLargeScreen! ? 2.0 : 10.0
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, availableWidth/scaleFactor, availableHeight/4.0, 0.0)
        
        //turn off highlight for custom highlighting
        button.adjustsImageWhenHighlighted = false
        button.backgroundColor = .white
        
        //call google sign in
        button.addTarget(self, action: #selector(googleSignInPressed), for: .touchUpInside)
        
        //handle button highlight
        button.addTarget(self, action: #selector(highlightButton(sender:)), for: .touchDown)
        button.addTarget(self, action: #selector(unhighlightButton(sender:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(unhighlightButton(sender:)), for: .touchUpOutside)
        
        button.clipsToBounds = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        view.addSubview(button)
        
        /*
         add constraints to login here. Currently made to sit below main stack view and be of same width
         of stackView and same height as the username rect and have a space between facebook and google
         */
        
        let topConstraintSpace: CGFloat = (isLargeScreen!) ? 10.0 : 5.0 //space to button above
        let leadingConstraint = NSLayoutConstraint(item: button, attribute: .leading, relatedBy: .equal, toItem: self.mainStackView, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: button , attribute: .top, relatedBy: .equal, toItem: below, attribute: .bottom, multiplier: 1.0, constant: topConstraintSpace)
        let heightConstraint = NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: self.password_textfield, attribute: .height, multiplier: 1.0, constant: 0.0)
        let widthConstraint  = NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: self.mainStackView, attribute: .width, multiplier: 1.0, constant: 0.0)
        
        NSLayoutConstraint.activate([leadingConstraint, topConstraint, heightConstraint, widthConstraint])
        
        return button
    }
    
    
    //required local wrapper for google sigin
    func googleSignInPressed() {
        print(Auth.auth().currentUser)
        GIDSignIn.sharedInstance().signIn()
    }
    
    //google sign in delegate protocol. Used for when user has signed in with google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("Some error with google sign in = \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) {[weak self] (user, error) in
            self?.login(user: user, error: error)
        }
    }
    
    
    //google sign in delegate protocol for disconnection
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        
        print("Google Sign In: User disconnected from app ")
    }
    
    
    //google logout
    func logOutWithGoogle() {
        GIDSignIn.sharedInstance().signOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("Logged Out")
    }
    
}


// extension for email login
extension LoginController {
    
    //signup button handler
    @IBAction func signupPressed() {
        if let username = username_textfield.text, let pw = password_textfield.text {
            if (username == "" || pw == "" || username.hasWhitespace() || pw.hasWhitespace()){
                //if contains whitespace or is empty string
                Utils.displayAlert(with: self, title: "No spaces allowed!", message: "Please remove all spaces from input.", text: "OK")
                return
            }
            
            if (username.isNumeric()) {
                
            }
            
            //validate username
            if (!username.validateEmail()) {
              Utils.displayAlert(with: self, title: "Email address is invalid!", message: "Please use a valid email address.", text: "OK")
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
                        Utils.displayAlert(with: self!, title: title, message: message, text: "OK")
                    }
                }
                else {
                    Utils.displayAlert(with: self!, title: "Unexpected Error", message: "Please try again later.", text: "OK")
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
                                Utils.displayAlert(with: self!, title: title, message: message, text: "OK")
                            }
                        }
                        else {
                            Utils.displayAlert(with: self!, title: "Unexpected Error", message: "Please try again later.", text: "OK")
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            Utils.displayAlert(with: self!, title: "Validation email sent!", message: "Please validate the entered email.", text: "OK") {
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
                Utils.displayAlert(with: self, title: "No spaces allowed!", message: "Please remove all spaces from input.", text: "OK")
                self.username_textfield.text = ""
                self.password_textfield.text = ""
                return
            }
            
            //for debugging purposes
            if(username == "a" && pw == "p") {
                performSegue(withIdentifier: "Map" , sender: nil)
                return
            }
            
            emailLogin(username: username, pw: pw)
        }
    }
    
    //login with mail method
    private func emailLogin(username: String, pw: String) {
        Auth.auth().signIn(withEmail: username, password: pw) {[weak self] (user, error) in
            self?.login(user: user, error: error)
        }
    }
    
    
    //login generic
    fileprivate func login(user: User?, error: Error?) {
        if let _ = user {
            performSegue(withIdentifier: "Login" , sender: nil)
        }
            
        else {
            Utils.handleSignInError(error: error, controller: self)
        }
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

