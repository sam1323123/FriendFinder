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
import ExpandableCell
import FontAwesome_swift

class MenuViewController: UIViewController {

    var menuOptions: [MenuItem]?
    
    var notificationCellRef: NotificationTableViewCell? //used for async updates of notif count
    
    var expandedCell: MenuViewCell?
    
    @IBOutlet var tableView: ExpandableTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initOptions()
        tableView.expandableDelegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
        expandedCell?.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
        expandedCell?.isExpanded = false
        tableView.closeAll()
    }
    

    /* MARK: - Table view data source

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
    */

    func initOptions() {
        let pals = MenuItem(name: "Pals", segueID: "PalMenu")
        let connections = MenuItem(name: "Connections", segueID: "Connection Menu")
        let notifs = MenuItem(name: "Notifications", segueID: "Notifications Menu")
        let invites = MenuItem(name: "Invites", segueID: "Invite Menu")
        menuOptions = [pals, connections, notifs, invites]
    }

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

// expandable menu cell delegate
extension MenuViewController: ExpandableDelegate {
    
     // called when cell is selected; returns expanded cells
     func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        if (menuOptions![indexPath.row].name == "Invites" ) {
            let fbCell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuViewCell
            let phoneCell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuViewCell
            fbCell.itemNameLabel.text = "Facebook Invites"
            phoneCell.itemNameLabel.text = "Text Invites"
            return [fbCell, phoneCell]
        }
                return nil
    }
    
    // called when cell is selected; returns expanded heights
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        if (menuOptions![indexPath.row].name == "Invites" ) {
            return Array(repeating: expandableTableView.rowHeight, count: 2)
        }
        return nil
    }
    
    func numberOfSections(in tableView: ExpandableTableView) -> Int {
        return 1
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return (menuOptions != nil) ? menuOptions!.count : 0
    }
    
    // called when any row is selected
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: item!.segueID, sender: nil)
        let item = menuOptions![indexPath.row]
        if (item.name == "Invites" ) {
            expandedCell!.isExpanded = !(expandedCell!.isExpanded)
            expandedCell!.arrowLabel.text = String.fontAwesomeIcon(name: (expandedCell!.isExpanded) ? .minus : .chevronRight)
        }
        else if(item.name == "Notifications") {
            performSegue(withIdentifier: item.segueID, sender: self)
        }
        
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectExpandedRowAt indexPath: IndexPath) {
    }
    
    // called when expanded row is selected
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCell: UITableViewCell, didSelectExpandedRowAt indexPath: IndexPath) {
        if let cell = expandedCell as? MenuViewCell {
            if cell.itemNameLabel.text == "Facebook Invites" {
                let inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
                if(inviteDialog.canShow()){
                    let appLinkUrl = NSURL(string: "https://fb.me/161411357746168")!
                    let previewImageUrl = NSURL(string: "https://yt3.ggpht.com/-wWokYDYoBLo/AAAAAAAAAAI/AAAAAAAAAAA/BobFfDIDo6o/s900-c-k-no-mo-rj-c0xffffff/photo.jpg")!
                    let inviteContent:FBSDKAppInviteContent = FBSDKAppInviteContent()
                    inviteContent.appLinkURL = appLinkUrl as URL!
                    inviteContent.appInvitePreviewImageURL = previewImageUrl as URL!
                    inviteDialog.content = inviteContent
                    inviteDialog.delegate = self
                    inviteDialog.show()
                }
            }
            if cell.itemNameLabel.text == "Text Invites" {
                let controller = TextMessageViewController()
                present(controller, animated: true, completion: nil)
            }

        }
    }
    
    // called to get all cells
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = menuOptions![indexPath.row]
        if (item.name == "Invites" ) {
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuViewCell else {
                return UITableViewCell()
            }
            cell.itemNameLabel.text = item.name
            cell.itemIcon.image = item.icon
            cell.arrowLabel.font = UIFont.fontAwesome(ofSize: cell.itemNameLabel.font.pointSize)
            cell.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
            expandedCell = cell
            expandedCell?.isExpanded = false
            return cell
        }
        else if (item.name == "Notifications") {
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "NotificationMenuCell", for: indexPath) as? NotificationTableViewCell else {
                return UITableViewCell()
            }
            cell.itemNameLabel.text = item.name
            cell.itemIcon.image = item.icon
            cell.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
            let pendingNotifs = PendingNotificationObject.sharedInstance.numberOfPendingRequests()
            if( pendingNotifs == 0) {
                //make invisible
                cell.countLabel.backgroundColor = UIColor.clear
                cell.countLabel.text = nil
            }
            else {
                cell.countLabel.backgroundColor = UIColor.red
                cell.countLabel.text = String(pendingNotifs) // set text to number of pending notifs
            }
            cell.recalibrateComponents()
            notificationCellRef = cell
            return cell
        }
        else {
            // default case i.e all other menu options
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuViewCell else {
                return UITableViewCell()
            }
            cell.itemNameLabel.text = item.name
            cell.itemIcon.image = item.icon
            return cell
    
        }
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return expandableTableView.rowHeight
    }
}

extension MenuViewController: FBSDKAppInviteDialogDelegate {

    // callback after invite dialog appears
    func appInviteDialog (_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        let results = results ??  [AnyHashable : Any]()
        let resultObject = NSDictionary(dictionary: results)
        if let didCancel = resultObject.value(forKey: "completionGesture")
        {
            if (didCancel as AnyObject).caseInsensitiveCompare("Cancel") == ComparisonResult.orderedSame
            {
                print("User Canceled invitation dialog")
            }
        }
    }
    
    // callback on failure to show dialog
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Error tool place in appInviteDialog \(error)")
    }
    
}





