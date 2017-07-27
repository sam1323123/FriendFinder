//
//  NextViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 6/23/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseAuth

class NextViewController: UIViewController {

    @IBOutlet var NextLabel: UILabel!
    var user: User?
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("At Next View Controller")
        navBar.delegate = self
        backButton.target = self
        backButton.action = #selector(goBack)
        user = Auth.auth().currentUser
        if let verified = user?.isEmailVerified{
            if(!verified) {
                // display warning
                displayAlert(title: "Account Unverified", message: "Access to certain account features is restricted. Please verify your account first", text: "OK")

            }
            
        }
        else {
            // should not happen
            displayAlert(title: "Should not happen", message: "User should not be nil", text: "OK")
            
        }

        // Do any additional setup after loading the view.
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
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
}



extension NextViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        print(" navBar Delegate called")
        return UIBarPosition.top
    }
    
}
