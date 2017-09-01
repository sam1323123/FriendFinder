//
//  NotificationDetailViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 8/26/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit
import ExpandableCell

class NotificationDetailViewController: UIViewController {

    
    @IBOutlet weak var tableView: ExpandableTableView!
    
    struct notificationDetails {
        var name: String
        var icon: UIImage?
    }
    
    var data: [notificationDetails] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.expandableDelegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        let names = PendingNotificationObject.sharedInstance.getAllPendingRequests()
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
}


extension NotificationDetailViewController: ExpandableDelegate {
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        return nil
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        return nil
    }
    
    func numberOfSections(in tableView: ExpandableTableView) -> Int {
        return 1
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectExpandedRowAt indexPath: IndexPath) {
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCell: UITableViewCell, didSelectExpandedRowAt indexPath: IndexPath) {
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.row]
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "notificationCell") as? NotificationSelectionCell else {
            return UITableViewCell()
        }
        cell.itemNameLabel.text = item.name
        cell.acceptButton.username = item.name
        cell.declineButton.username = item.name
        cell.acceptButton.addTarget(self, action: #selector(handleAcceptNotification(sender:)), for: .touchUpInside)
        cell.declineButton.addTarget(self, action: #selector(handleDeclineNotification(sender:)), for: .touchUpInside)
        return cell
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return expandableTableView.rowHeight
    }
}



