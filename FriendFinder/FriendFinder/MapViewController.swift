//
//  MapViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/2/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

  
    @IBOutlet var mapScrollView: UIScrollView! {
        didSet {
            mapScrollView.delegate = self
        }
    }
    
    @IBOutlet fileprivate var mapImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

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

}




extension MapViewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImageView
    }
    
}
