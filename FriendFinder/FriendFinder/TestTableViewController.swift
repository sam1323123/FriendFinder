//
//  TestTableViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 8/30/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class TestTableViewController: UITableViewController {

    struct notificationDetails {
        var name: String
        var icon: UIImage?
    }
    
    var data: [notificationDetails] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let names = PendingNotificationObject.sharedInstance.getAllPendingRequests()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        for name in names {
            //populate data array
            let elem = notificationDetails(name: name, icon: nil)
            data.append(elem)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PendingNotificationObject.sharedInstance.registerObserver(observer: self, action: #selector(handleNotification(_:)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PendingNotificationObject.sharedInstance.removeObserver(observer: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleNotification(_ notification: NSNotification) {
        let names = PendingNotificationObject.sharedInstance.getAllPendingRequests()
        var newData: [notificationDetails] = []
        for name in names {
            newData.append(notificationDetails(name: name, icon: nil))
        }
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
    
    //TODO add logic to send accept notif to counterparty
    func handleAcceptNotification(sender: UIButton) {
        guard let sender = sender as? NotificationSelectionButton else {
            return
        }
        PendingNotificationObject.sharedInstance.removeRequest(username: sender.username ?? "")
    }
    
    //TODO add logic to send decline notif to counterparty
    func handleDeclineNotification(sender: UIButton) {
        guard let sender = sender as? NotificationSelectionButton else {
            return
        }
        PendingNotificationObject.sharedInstance.removeRequest(username: sender.username ?? "")
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
        cell.acceptButton.username = item.name
        cell.declineButton.username = item.name
        cell.acceptButton.addTarget(self, action: #selector(handleAcceptNotification(sender:)), for: .touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(handleDeclineNotification(sender:)), for: .touchUpInside)
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
