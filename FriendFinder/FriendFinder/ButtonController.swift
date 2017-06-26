//
//  ButtonController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 6/21/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class ButtonController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadAndSetImageBackground()
    }
    
    private func loadAndSetImageBackground() {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageView.image = #imageLiteral(resourceName: "waves")
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.view.addSubview(imageView)
        self.view.sendSubview(toBack: imageView)
        
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
        else {
            print("wrong cast")
        }
        
    }

    

}
