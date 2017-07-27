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
    
    @IBOutlet weak var backButton: UIBarButtonItem! //back button of the navBar
    
    @IBOutlet weak var placeNameLabel: UILabel!
    var placeName: String?
    
    @IBOutlet weak var placeImageView: UIImageView!
    var placeImage: UIImage? = nil
    
    @IBOutlet weak var addressLabel: UILabel!
    var address: String?
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    var phoneNumber: String?
    
    @IBOutlet weak var placeHoursLabel: UILabel!
    var placeHours: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.delegate = self
        
        //initialize all labels with string values
        placeNameLabel.text = placeName
        placeImageView.image = placeImage
        addressLabel.text = address
        phoneNumberLabel.text = phoneNumber
        placeHoursLabel.text = placeHours
        
        //configure navBar back button
        backButton.target = self
        backButton.action = #selector(goBack)
        
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
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
}


extension LocationDetailViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.top
    }
    
    
}
