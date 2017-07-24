//
//  LocationDetailViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/22/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeImageView: UIImageView!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var placeHoursLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.delegate = self
        
        //set the custom action handling for navBar back button
        let backButton = self.navBar.topItem?.leftBarButtonItem
        backButton?.target = self
        backButton?.action = #selector(goBack)
        
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

    
    //dismiss the view controller. Used by back button
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
}


extension LocationDetailViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.top
    }
    
    
}
