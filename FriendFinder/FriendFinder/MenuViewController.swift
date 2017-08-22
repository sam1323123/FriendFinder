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
        print("LOADED")
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

extension MenuViewController: ExpandableDelegate {
    
     func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        if (menuOptions![indexPath.row].name == "Invites" ) {
            let fbCell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuViewCell
            let phoneCell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuViewCell
            fbCell.itemNameLabel.text = "Facebook Invites"
            phoneCell.itemNameLabel.text = "Phone Invites"
            return [fbCell, phoneCell]
        }
        return nil
    }
    
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
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuOptions![indexPath.row]
        //performSegue(withIdentifier: item!.segueID, sender: nil)
        if (menuOptions![indexPath.row].name == "Invites" ) {
            expandedCell!.isExpanded = !(expandedCell!.isExpanded)
            expandedCell!.arrowLabel.text = String.fontAwesomeIcon(name: (expandedCell!.isExpanded) ? .minus : .chevronRight)
        }
        
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectExpandedRowAt indexPath: IndexPath) {
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCell: UITableViewCell, didSelectExpandedRowAt indexPath: IndexPath) {
        if let cell = expandedCell as? MenuViewCell {
            print("\(cell.itemNameLabel.text ?? "")")
        }
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "MenuCell") as? MenuViewCell else {
            return UITableViewCell()
        }
        cell.itemNameLabel.text = menuOptions![indexPath.row].name
        if (menuOptions![indexPath.row].name == "Invites" ) {
            cell.arrowLabel.font = UIFont.fontAwesome(ofSize: cell.itemNameLabel.font.pointSize)
            cell.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
            expandedCell = cell
        }
        return cell
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return expandableTableView.rowHeight
    }
}


