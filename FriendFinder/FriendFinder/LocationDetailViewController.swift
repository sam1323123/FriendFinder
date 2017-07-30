//
//  LocationDetailViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/22/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FontAwesome_swift

class LocationDetailViewController: UIViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem! //back button of the navBar
    
    @IBOutlet weak var placeNameLabel: UILabel!
    var placeName: String?
    
    @IBOutlet weak var placeImageView: UIImageView!
    var placeImage: UIImage? = nil
    
    @IBOutlet weak var addressLabel: UILabel!
    var address: String?
    
    @IBOutlet weak var phoneButton: UIButton!
    var phone: String?
    
    @IBOutlet weak var webButton: UIButton!
    var web: URL?

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
        let backButton = self.navBar.topItem?.leftBarButtonItem
        backButton?.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 25.0)], for: .normal)
        
        //initialize all labels with string values
        placeNameLabel.text = placeName
        placeImageView.image = placeImage
        addressLabel.text = address
        phoneButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        phoneButton.setTitle(String.fontAwesomeIcon(name: .phone), for: .normal)
        phoneButton.setTitleColor(.black, for: .normal)
        webButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
        webButton.setTitle(String.fontAwesomeIcon(name: .info), for: .normal)
        webButton.setTitleColor(.black, for: .normal)
        placeHoursLabel.text = placeHours

        
        //configure navBar back button
        backButton?.target = self
        backButton?.action = #selector(goBack)
        
        // Do any additional setup after loading the view.
        portraitConstraints = [placeImageWidthConstraint,
                              placeImageViewHeightConstraint,
                              stackViewTopConstraint,
                              stackViewLeadingConstraint]
        landscapeConstraints = makeLandscapeConstraints()
        self.setViewConstraintsByOrientation()
        
        //add spinner reference to image view
        if let sp = spinner {
            placeImageView.addSubview(sp)
        }
        phoneButton.addTarget(self, action: #selector(clickOnPhone), for: .touchUpInside)
        webButton.addTarget(self, action: #selector(clickOnWeb), for: .touchUpInside)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setViewConstraintsByOrientation() {
        let orient = UIApplication.shared.statusBarOrientation
        if(orient.isPortrait) {
            self.view.removeConstraints((self.landscapeConstraints))
            self.view.addConstraints((self.portraitConstraints))
        }
        else {
            //landscape
            self.view.removeConstraints((self.portraitConstraints))
            self.view.addConstraints((self.landscapeConstraints))
        }
    }
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: {[weak self] (UIViewControllerTransitionCoordinatorContext) -> Void in
            /*
            let orient = UIApplication.shared.statusBarOrientation
            if(orient.isPortrait) {
                self?.view.removeConstraints((self?.landscapeConstraints)!)
                self?.view.addConstraints((self?.portraitConstraints)!)
            }
            else {
                //landscape 
                self?.view.removeConstraints((self?.portraitConstraints)!)
                self?.view.addConstraints((self?.landscapeConstraints)!)
            }*/
            self?.setViewConstraintsByOrientation()
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
        let leftMargin: CGFloat = 10.0
        let stackViewLeadingConstraint = NSLayoutConstraint(item: labelStack, attribute: .leading, relatedBy: .equal, toItem: placeImageView, attribute: .trailing, multiplier: 1.0, constant: leftMargin)
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

extension LocationDetailViewController {
    
    // phone link open handler
    func clickOnPhone() {
        guard let number = phone else {
            Utils.displayAlert(with: self, title: "Sorry", message: "No phone available!", text: "OK")
            return
        }
        if let url = URL(string: "tel://\(number)") {
            if UIApplication.shared.canOpenURL(url) {
                Utils.displayAlertWithCancel(with: self, title: "\(number)", message: "", text: "Call" , callback: {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                })
            }
            else {
                Utils.displayAlert(with: self, title: "Sorry!", message: "Device cannot make call now.", text: "OK")
            }
        }
    }

    
    // web link open handler
    func clickOnWeb() {
        if let url = web {
            if UIApplication.shared.canOpenURL(url) {
                Utils.displayAlertWithCancel(with: self, title:  "This page will open in the browser.", message: "", text: "Open" , callback: {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                })
            }
            else {
                Utils.displayAlert(with: self, title: "Sorry!", message: "Device cannot open URL now.", text: "OK")
            }
        }
    }
}


