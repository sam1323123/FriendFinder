//
//  TestTableViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 8/30/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SideMenu

class NotificationDetailViewController: UITableViewController {

    private var ref: DatabaseReference! = Database.database().reference()
    private var username = UserDefaults.standard.value(forKey: "username") as? String
    private var preferredName = UserDefaults.standard.value(forKey: "name") as? String

    private var hasLoaded = false
    
    private var data = [FFUser]() {
        didSet {
            if data.isEmpty && hasLoaded {
                Utils.displayFiller(for: tableView, width: SideMenuManager.menuWidth, center: CGPoint(x: (tableView.frame.minX + SideMenuManager.menuWidth) * 0.5, y: tableView.center.y))
            }
            else if oldValue.isEmpty && !data.isEmpty && hasLoaded {
                if let viewWithTag = view.viewWithTag(Utils.imageViewFillerTag) {
                    viewWithTag.removeFromSuperview()
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        let usernames = PendingNotificationObject.sharedInstance.getAllPendingRequests()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        for username in usernames.keys {
            //populate data array
            let elem = FFUser(name: usernames[username]!, username: username)
            data.append(elem)
        }
        initializeNavbar()
        print(tableView.center, tableView.frame.minX, tableView.frame.maxX )

        if data.isEmpty {
            Utils.displayFiller(for: tableView, width: tableView.frame.width * 0.75, center: CGPoint(x: (tableView.frame.minX + tableView.frame.width * 0.75) * 0.5, y: tableView.center.y))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PendingNotificationObject.sharedInstance.registerObserver(observer: self, action: #selector(handleNotification(_:)))
        AcceptedConnectionsObject.sharedInstance.registerObserver(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PendingNotificationObject.sharedInstance.removeObserver(observer: self)
        AcceptedConnectionsObject.sharedInstance.removeObserver(observer: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeNavbar() {
        let name = UserDefaults.standard.value(forKey: "name") as! String
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let imageData = UserDefaults.standard.value(forKey: "profileImage") as? Data
        let navbarNib = UINib(nibName: "navbarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SideMenuNavbar
        if(navbarNib == nil) {
            print("COULD NOT FIND NIB FILE")
            return
        }
        let navView = navbarNib!
        var image: UIImage?
        if let imageData = imageData {
            print("Retrieved imagedata")
            image = UIImage(data: imageData)
        }
        navView.awakeAndInitialize(image: image, name: name, username: username)
        navigationItem.titleView = navView
        
        print("initialized!!!!!!")
        
    }
    
    func handleNotification(_ notification: NSNotification) {
        let usernames = PendingNotificationObject.sharedInstance.getAllPendingRequests()
        var newData: [FFUser] = []
        for username in usernames.keys {
            newData.append(FFUser(name: usernames[username]!, username: username))
        }
        hasLoaded = true
        data = newData
        tableView.reloadSections(IndexSet(0...0), with: UITableViewRowAnimation.left)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func handleAcceptPressed(sender: UIButton) {
        guard let username = self.username, let preferredName = self.preferredName else {
            print("USERNAME AND PREFERREDNAME NOT SET IN NotificatioDetail VC")
            return //error case should not happen
        }
        guard let sender = sender as? UserSelectionButton else {
            return
        }
        //insert accept message to counter party's connections field
        let user = sender.user
        let acceptMessage = ["\(username)":["name": preferredName, "accepted": "true"]]
        ref.child(FirebasePaths.connectionRequestReply(username: user!.username)).updateChildValues(acceptMessage, withCompletionBlock: {(err, dbRef) in
            if let err = err {
                print("Cannot Write Accept Message: \(acceptMessage) because of \(err)")
                return
            }
            //no error so remove entry. Following call automatically reloads data due to listener
            PendingNotificationObject.sharedInstance.removeRequest(username: user!.username)
            
            //insert into locationTo table
            self.ref.child(FirebasePaths.locationReceivers(uid: Auth.auth().currentUser!.uid)).updateChildValues([user!.username: "Placeholder for pubnub"], withCompletionBlock: {(err, dbref) in
                if let err = err {
                    print("locationsTo update failed due to \(err)")
                    return
                }})
        })

    }
    
    
    func handleDeclinePressed(sender: UIButton) {
        guard let username = self.username else {
            print("USERNAME AND PREFERREDNAME NOT SET IN NotificatioDetail VC")
            return //error case should not happen
        }
        guard let sender = sender as? UserSelectionButton else {
            return
        }
        //insert accept message to counter party's connections field
        let user = sender.user
        let declineMessage = ["\(username)":["name": preferredName, "accepted": "false"]]
        ref.child(FirebasePaths.connectionRequestReply(username: user!.username)).updateChildValues(declineMessage, withCompletionBlock: {(err, dbRef) in
            if let err = err {
                print("Cannot Decline because of \(err)")
                return
            }
            //no error so remove entry. Following call automatically reloads data due to listener
            PendingNotificationObject.sharedInstance.removeRequest(username: user!.username ?? "")
        })
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let item = data[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "testCell1") as? NotificationSelectionCell else {
            return UITableViewCell()
        }
        cell.itemNameLabel.text = item.name
        let user = FFUser(name: "", username: item.username)
        cell.acceptButton.user = user
        cell.declineButton.user = user
        cell.acceptButton.addTarget(self, action: #selector(handleAcceptPressed(sender:)), for: .touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(handleDeclinePressed(sender:)), for: .touchUpInside)
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
