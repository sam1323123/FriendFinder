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
        let item = menuOptions![indexPath.row]
        //performSegue(withIdentifier: item!.segueID, sender: nil)
        if (menuOptions![indexPath.row].name == "Invites" ) {
            expandedCell!.isExpanded = !(expandedCell!.isExpanded)
            expandedCell!.arrowLabel.text = String.fontAwesomeIcon(name: (expandedCell!.isExpanded) ? .minus : .chevronRight)
        }
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
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuViewCell else {
            return UITableViewCell()
        }
        cell.itemNameLabel.text = menuOptions![indexPath.row].name
        if (menuOptions![indexPath.row].name == "Invites" ) {
            cell.arrowLabel.font = UIFont.fontAwesome(ofSize: cell.itemNameLabel.font.pointSize)
            cell.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
            expandedCell = cell
            expandedCell?.isExpanded = false
        }
        return cell
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





