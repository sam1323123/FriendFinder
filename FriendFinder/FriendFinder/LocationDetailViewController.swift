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
    
    var spinner: UIActivityIndicatorView?
    
    
    @IBOutlet weak var labelStack: UIStackView!
    
    //constraint outlets
    
    @IBOutlet weak var placeImageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var placeImageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    
    var portraitConstraints: [NSLayoutConstraint] = []
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.delegate = self
        self.navBar.shadowImage = UIImage()
        self.navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default) //required for transparent bacground
        
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
        portraitConstraints = [placeImageWidthConstraint,
                              placeImageViewHeightConstraint,
                              stackViewTopConstraint,
                              stackViewLeadingConstraint]
        landscapeConstraints = makeLandscapeConstraints()
        
        //add spinner reference to image view
        if let sp = spinner {
            placeImageView.addSubview(sp)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: {[weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            if(orient.isPortrait) {
                self?.view.removeConstraints((self?.landscapeConstraints)!)
                self?.view.addConstraints((self?.portraitConstraints)!)
            }
            else {
                //landscape 
                self?.view.removeConstraints((self?.portraitConstraints)!)
                self?.view.addConstraints((self?.landscapeConstraints)!)
            }
            }, completion: {(UIViewControllerTransitionCoordinatorContext) -> Void in
        print("Rotation in LoacationDetail completed")})
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //functions for modifying view constraints
    func makeLandscapeConstraints() -> [NSLayoutConstraint] {
        //width of image
        let imageWidthConstraint = NSLayoutConstraint(item: placeImageView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.5, constant: 0.0)
        
        //height of image
        /*let imageTopConstraint = NSLayoutConstraint(item: placeImageView, attribute: .top, relatedBy: .equal, toItem: navBar, attribute: .bottom, multiplier: 1.0, constant: 0.0)
 */
        let imageBottomConstraint = NSLayoutConstraint(item: placeImageView, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0.0)
        
        //height of stackView
        let stackViewTopConstraint = NSLayoutConstraint(item: labelStack, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        
        //x start/width of stackView
        let stackViewLeadingConstraint = NSLayoutConstraint(item: labelStack, attribute: .leading, relatedBy: .equal, toItem: placeImageView, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        //don't have to change stackView Bottom constraint
        return [imageWidthConstraint,  imageBottomConstraint,
                stackViewTopConstraint, stackViewLeadingConstraint]

    }
    
    func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
}


extension LocationDetailViewController: UINavigationBarDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.top
    }
    
    
}
