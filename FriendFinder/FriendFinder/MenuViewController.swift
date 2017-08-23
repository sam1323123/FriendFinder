//
//  MenuViewController.swift
//  FriendFinder
//
//  Created by Avi on 8/13/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import SideMenu
import FBSDKCoreKit
import FBSDKShareKit

class MenuViewController: UITableViewController {

    var menuOptions: [MenuItem]?
    var notificationCellRef: NotificationTableViewCell? //used for async updates of notif count

    override func viewDidLoad() {
        super.viewDidLoad()
        initOptions()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PendingNotificationObject.sharedInstance.registerObserver(observer: self, action: #selector(notificationHandler(_:)) )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PendingNotificationObject.sharedInstance.removeObserver(observer: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // reenable map panning
        MapViewController.disableMapPanning = false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (menuOptions != nil) ? menuOptions!.count : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = menuOptions?[indexPath.row]
        if(indexPath.row == 2) { //index of notification option
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath)
            notificationCellRef = (cell as! NotificationTableViewCell)
            notificationCellRef!.itemNameLabel.text = item?.name
            notificationCellRef!.itemIcon.image = item?.icon
            let pendingNotifs = PendingNotificationObject.sharedInstance.numberOfPendingRequests()
            if( pendingNotifs == 0) {
                //make invisible
                notificationCellRef!.countLabel.backgroundColor = UIColor.clear
                notificationCellRef!.countLabel.text = nil
            }
            else {
                notificationCellRef!.countLabel.backgroundColor = UIColor.red
                notificationCellRef!.countLabel.text = String(pendingNotifs) // set text to number of pending notifs
            }
            notificationCellRef!.recalibrateComponents()
            return notificationCellRef!

        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
            let menuCell = cell as! MenuViewCell
            menuCell.itemNameLabel.text = item?.name
            menuCell.itemIcon.image = item?.icon
            return menuCell
        }
        
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuOptions?[indexPath.row]
        performSegue(withIdentifier: item!.segueID, sender: nil)
    }
    
    func initOptions() {
        let pals = MenuItem(name: "Pals", segueID: "PalMenu")
        let connections = MenuItem(name: "Connections", segueID: "Connection Menu")
        let notif = MenuItem(name: "Notifications", segueID: "Notifications Menu")
        menuOptions = [pals, connections, notif]
    }

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
    
    func notificationHandler(_ args: NSNotification) {
        guard let cell = notificationCellRef else {
            return
        }
        let numNotifs = PendingNotificationObject.sharedInstance.numberOfPendingRequests()
        if(numNotifs == 0) {
            //make notif box invisible
            cell.backgroundColor = UIColor.clear
            cell.countLabel.text = nil
            //don't have to recalibrate
        }
        else {
            cell.backgroundColor = UIColor.red
            cell.countLabel.text = String(numNotifs)
        }
    }
}



