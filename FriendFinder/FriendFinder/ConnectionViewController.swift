//
//  InvitesViewController.swift
//  FriendFinder
//
//  Created by Avi on 8/20/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SideMenu

class ConnectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    private let dbRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    
    private var users = [FFUser]()
    private var usernames: [String]!
    private var nameMap = [String:String]()
    private var iconMap = [String:UIImage]()
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    private var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem?.title = String.fontAwesomeIcon(name: .chevronLeft)
        initData()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.visibleViewController?.present(SideMenuManager.menuLeftNavigationController!, animated: true)
    }
    
    private func initData() {
        dbRef.child("usernames").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            self!.usernames = Array(data.keys)
            if let index = self!.usernames.index(of: MapViewController.currentController!.userName!) {
                self!.usernames.remove(at: index)
            }
            for username in self!.usernames {
                self!.nameMap[username] = (((data[username] as! [String:AnyObject])["name"])! as! String)
                self!.storageRef.child(FirebasePaths.userIcons(username: username)).getData(maxSize: 1 * 1024 * 1024) { data, error in
                    var image: UIImage
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print(error)
                        image = #imageLiteral(resourceName: "no_image")
                    } else {
                        image = UIImage(data: data!)!
                    }
                    self?.iconMap[username] = image
                    self?.users.append(FFUser(name: self!.nameMap[username]!, username: username, picture: image))
                }
            }
            self?.spinner.center = self!.tableView.center
            self?.tableView.addSubview(self!.spinner)
            self?.tableView.bringSubview(toFront: self!.spinner)
            self?.spinner.startAnimating()
            self?.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self!, selector: #selector(self?.checkDone), userInfo: nil, repeats: true)
        })
    }
    
    func checkDone() {
        if (users.count == usernames.count) {
            timer?.invalidate()
            spinner.stopAnimating()
            tableView.reloadSections(IndexSet(0...0), with: UITableViewRowAnimation.left)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (users.count)
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)

        // Configure the cell...
        let userCell = cell as! UserViewCell
        let user = users[indexPath.row]
        userCell.nameLabel.text = user.name
        userCell.usernameLabel.text = user.username
        userCell.userIcon.image = user.picture
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
