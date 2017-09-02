//
//  InvitesViewController.swift
//  FriendFinder
//
//  Created by Avi on 8/20/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SideMenu

class ConnectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    private let ref = Database.database().reference()
    private var users: [FFUser]!
    private var usernames: [String]!
    private var names: [String]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
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
        ref.child("usernames").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            self?.usernames = Array(data.keys)
            self?.names = data.keys.map({ (username) -> String in
                return ((data[username] as! [String:AnyObject])["name"]) as! String
            })
            self?.users = Array(0..<(self?.usernames.count ?? 0)).map( { [weak self] (index) -> FFUser in
                return FFUser(name: (self?.names![index])!, username: (self?.usernames![index])!)
            })
            self?.tableView.reloadSections(IndexSet(0...0), with: UITableViewRowAnimation.left)
        })
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
        return (users?.count ?? 0)
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)

        // Configure the cell...
        let userCell = cell as! UserViewCell
        userCell.nameLabel.text = users[indexPath.row].name
        userCell.usernameLabel.text = users[indexPath.row].username
        userCell.userIcon.image = #imageLiteral(resourceName: "no_image")
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
