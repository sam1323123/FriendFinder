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
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

class MenuViewController: UIViewController {
    
    struct MenuItem {
        var name: String
        var icon: UIImage?
        var segueID: String
        
        public init(name: String, segueID: String, icon: UIImage? = nil) {
            self.name = name
            self.segueID = segueID
            self.icon = icon
        }
    }
    
    
    enum Provider {
        case facebook
        case google
        case email
        
        func logOut() {
            switch self {
                case .facebook:
                    FBSDKLoginManager().logOut()
                case .google:
                    GIDSignIn.sharedInstance().signOut()
                default:
                    break
            }
        }
    }


    fileprivate let providerMap: [String:Provider] = ["facebook.com": .facebook, "google.com": .google, "password": .email]
    var menuOptions: [MenuItem]!
    
    var notificationCellRef: NotificationTableViewCell? //used for async updates of notif count
    
    var expandedInviteCell: MenuViewCell?
    
    @IBOutlet var tableView: ExpandableTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        let backImage = UIImage.fontAwesomeIcon(name: .chevronLeft, textColor: .orange, size: CGSize(width: 30, height: 30))
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationController?.navigationBar.tintColor = .orange
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orange]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.orange, NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline).setBold()]
        let barButton = UIBarButtonItem()
        barButton.title = " "
        navigationItem.backBarButtonItem = barButton
        initOptions()
        tableView.expandableDelegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        initializeNavbar()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PendingNotificationObject.sharedInstance.registerObserver(observer: self, action: #selector(notificationHandler(_:)) )
        AcceptedConnectionsObject.sharedInstance.registerObserver(observer: self)
        
        //reupdate view if necessary
        guard let cell = notificationCellRef else {
            return
        }
        let numNotifs = PendingNotificationObject.sharedInstance.numberOfPendingRequests()
        if(numNotifs == 0) {
            //make notif box invisible
            cell.countLabel.backgroundColor = UIColor.clear
            cell.countLabel.text = nil
            //don't have to recalibrate
        }
        else {
            cell.countLabel.backgroundColor = UIColor.red
            cell.countLabel.text = String(numNotifs)
            cell.recalibrateComponents()
        }
        
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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // reenable map panning
        MapViewController.disableMapPanning = false
        expandedInviteCell?.arrowLabel.text = String.fontAwesomeIcon(name: .chevronDown)
        expandedInviteCell?.isExpanded = false
        tableView.closeAll()
    }
    
    
    func initializeNavbar() {
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let imageData = UserDefaults.standard.value(forKey: "profileImage") as? Data
        let navbarNib = UINib(nibName: "navbarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? SideMenuNavbar
        if(navbarNib == nil) {
            print("COULD NOT FIND NIB FILE")
            return
        }
        let navView = navbarNib!
        var image: UIImage? = nil
        if let imageData = imageData {
            image = UIImage(data: imageData)
        }
        navView.awakeAndInitialize(image: image, title: username)
        
        //navigationController?.navigationItem.titleView = navView
        navigationItem.titleView = navView
        
        print("initialized!!!!!!")
        /*print((navigationController?.navigationItem.titleView as! SideMenuNavbar).titleLabel.text)
        print((navigationController?.navigationItem.titleView as! SideMenuNavbar).bounds.size)
        */
        
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
        let pals = MenuItem(name: "Pals", segueID: "Current Pals Menu")
        let connections = MenuItem(name: "Make Pals", segueID: "Make Pals Menu")
        let notifs = MenuItem(name: "Notifications", segueID: "Notifications Menu")
        let invites = MenuItem(name: "Invites", segueID: "Invite Menu")
        let logOut = MenuItem(name: "Log Out", segueID: "Log Out")
        menuOptions = [pals, connections, notifs, invites, logOut]
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
            cell.countLabel.backgroundColor = UIColor.clear
            cell.countLabel.text = nil
            //don't have to recalibrate
        }
        else {
            cell.countLabel.backgroundColor = UIColor.red
            cell.countLabel.text = String(numNotifs)
            cell.recalibrateComponents()
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
        let item = menuOptions![indexPath.row]
        if (item.name == "Invites" ) {
            expandedInviteCell!.isExpanded = !(expandedInviteCell!.isExpanded)
            expandedInviteCell!.arrowLabel.text = String.fontAwesomeIcon(name: (expandedInviteCell!.isExpanded) ? .minus : .chevronDown)
        }
        else if (item.name == "Notifications") {
            SideMenuManager.menuPushStyle = .subMenu
            performSegue(withIdentifier: item.segueID, sender: self)
        }
        else if (item.name == "Log Out") {
            SideMenuManager.menuPushStyle = .defaultBehavior
            Utils.displayAlertWithCancel(with: self, title: "Log Out", message: "Are you sure you want to do this?", text: "Yes", style: .destructive,callback: { [weak self] in
                do {
                    let provider = (self?.providerMap[(Auth.auth().currentUser?.providerData.first?.providerID)!]!)!
                    try Auth.auth().signOut()
                    provider.logOut()
                    self!.performSegue(withIdentifier: "Back To Login", sender: self)
                } catch let error as NSError {
                    Utils.handleSignInError(error: error, controller: self!)
                }
            })
        }
        else {
            SideMenuManager.menuPushStyle = .defaultBehavior
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

            cell.arrowLabel.text = String.fontAwesomeIcon(name: .chevronDown)
            expandedInviteCell = cell
            expandedInviteCell?.isExpanded = false
            return cell
        }
        else if (item.name == "Notifications") {
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "NotificationMenuCell", for: indexPath) as? NotificationTableViewCell else {
                return UITableViewCell()
            }
            cell.itemNameLabel.text = item.name
            cell.itemIcon.image = item.icon
            cell.arrowLabel.font = UIFont.fontAwesome(ofSize: cell.itemNameLabel.font.pointSize)
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
            cell.arrowLabel.font = UIFont.fontAwesome(ofSize: cell.itemNameLabel.font.pointSize)
            cell.arrowLabel.text = String.fontAwesomeIcon(name: .chevronRight)
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





