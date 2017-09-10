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
import SwipeCellKit


class CurrentPalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var searchFooter: SearchFooter!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate let dbRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    
    fileprivate var hasLoaded = false
    
    fileprivate var broadcastingUsers = [FFUser]()
    private var broadcastingUsernames: [String]!
    private var broadcastingNameMap = [String:String]()
    private var broadcastingIconMap = [String:UIImage]()
    
    fileprivate var receivingUsers = [FFUser]()
    private var receivingUsernames: [String]!
    private var receivingNameMap = [String:String]()
    private var receivingIconMap = [String:UIImage]()
    
    fileprivate var filteredUsers = [FFUser]()
    
    fileprivate var users = [FFUser]() {
        didSet {
            if users.isEmpty && hasLoaded {
                Utils.displayFiller(for: tableView)
            }
            else if oldValue.isEmpty && !users.isEmpty && hasLoaded {
                if let viewWithTag = view.viewWithTag(Utils.imageViewFillerTag) {
                    viewWithTag.removeFromSuperview()
                }
            }
        }
    }
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    private var timer: Timer?
    
    enum Scope: String {
        case all
        case receive
        case broadcast
    }
    
    let scopeMap: [String:Scope] = ["Receive From": .receive, "Broadcasting To": .broadcast]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchController.searchBar.barTintColor = .lightTeal
        textFieldInsideSearchBar?.backgroundColor = .teal
        textFieldInsideSearchBar?.textColor = .white
        searchController.searchBar.scopeButtonTitles = Array(scopeMap.keys)
        searchController.searchBar.delegate = self
        searchController.searchBar.enablesReturnKeyAutomatically = true
        tableView.tableHeaderView = searchController.searchBar
        // Setup the search footer
        tableView.tableFooterView = searchFooter
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem?.title = String.fontAwesomeIcon(name: .chevronLeft)
        title = "Current Pals"
        initData()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AcceptedConnectionsObject.sharedInstance.registerObserver(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.visibleViewController?.present(SideMenuManager.menuLeftNavigationController!, animated: true)
        AcceptedConnectionsObject.sharedInstance.removeObserver(observer: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    fileprivate func filterContentForSearchText(_ searchText: String, scope: Scope = .all) {
        let broadcastMatch =  (scope == .broadcast)
        users = broadcastMatch ? broadcastingUsers : receivingUsers
        filteredUsers = users.filter({( user : FFUser) -> Bool in
            var filter = false
            filter ||= user.name.lowercased().contains(searchText.lowercased())
            filter ||= user.username.lowercased().contains(searchText.lowercased())
            return filter
        })
        tableView.reloadData()
    }
    
    fileprivate func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func initData() {
        // broadcast to receivers
        dbRef.child(FirebasePaths.locationReceivers(uid: (Auth.auth().currentUser?.uid)!)).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            let data = snapshot.value as? [String:AnyObject] ?? [:]
            self!.receivingUsernames = Array(data.keys)
            for username in self!.receivingUsernames {
                self!.dbRef.child(FirebasePaths.usernameProfileName(username: username)).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                    let name = snapshot.value as! String
                    self!.receivingNameMap[username] = name
                    self!.storageRef.child(FirebasePaths.userIcons(username: username)).getData(maxSize: 1 * 1024 * 1024) { data, error in
                        let image: UIImage
                        if let error = error {
                            // Uh-oh, an error occurred!
                            print(error)
                            image = #imageLiteral(resourceName: "no_image")
                        } else {
                            image = UIImage(data: data!)!
                        }
                        self?.receivingIconMap[username] = image
                        self?.receivingUsers.append(FFUser(name: self!.receivingNameMap[username]!, username: username, picture: image))
                    }
                })
            }
            self?.spinner.center = self!.tableView.center
            self?.tableView.addSubview(self!.spinner)
            self?.tableView.bringSubview(toFront: self!.spinner)
            self?.spinner.startAnimating()
            self?.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self!, selector: #selector(self?.checkDone), userInfo: nil, repeats: true)
        })
        // receive from broadcasters
        dbRef.child(FirebasePaths.locationBroadcasters(uid: (Auth.auth().currentUser?.uid)!)).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            let data = snapshot.value as? [String:AnyObject] ?? [:]
            self!.broadcastingUsernames = Array(data.keys)
            for username in self!.broadcastingUsernames {
                self!.dbRef.child(FirebasePaths.usernameProfileName(username: username)).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                    let name = snapshot.value as! String
                    self!.broadcastingNameMap[username] = name
                    self!.storageRef.child(FirebasePaths.userIcons(username: username)).getData(maxSize: 1 * 1024 * 1024) { data, error in
                        let image: UIImage
                        if let error = error {
                            // Uh-oh, an error occurred!
                            print(error)
                            image = #imageLiteral(resourceName: "no_image")
                        } else {
                            image = UIImage(data: data!)!
                        }
                        self?.broadcastingIconMap[username] = image
                        self?.broadcastingUsers.append(FFUser(name: self!.broadcastingNameMap[username]!, username: username, picture: image))
                    }
                })
            }
        })
    }
    
    func checkDone() {
        if (broadcastingUsers.count == broadcastingUsernames.count && receivingUsers.count == receivingUsernames.count) {
            timer?.invalidate()
            spinner.stopAnimating()
            tableView.reloadData()
            searchController.isActive = true
            hasLoaded = true
            if users.isEmpty {
                users = []
            }
        }
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredUsers.count, of: users.count)
        }
        else {
            searchFooter.setNotFiltering()
        }
        return isFiltering() ? filteredUsers.count : users.count
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)

        // Configure the cell...
        let userCell = cell as! UserViewCell
        userCell.delegate = self
        let user: FFUser
        if isFiltering() {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
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


extension CurrentPalsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = scopeMap[searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]]!
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

extension CurrentPalsViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = scopeMap[searchBar.scopeButtonTitles![selectedScope]]!
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

//extension for connecting to friend
extension CurrentPalsViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        /*let stopAction = SwipeAction(style: .default, title: "Stop") { action, indexPath in
            // handle action by updating model with deletion
            print("STOP")
        }
        stopAction.image = UIImage.fontAwesomeIcon(name: .stop, textColor: .orange, size: CGSize(width: 30, height: 30))
        stopAction.backgroundColor = .teal */
        let blockAction = SwipeAction(style: .destructive, title: "Block") {
            [weak self] action, indexPath in
            Utils.displayAlertWithCancel(with: self!, title: "Warning!", message: "Are you sure you want to do this?", text: "Yes", style: .destructive, callback: {
                let path: String
                let scope = self!.scopeMap[(Array(self!.scopeMap.keys))[self!.searchController.searchBar.selectedScopeButtonIndex]]!
                if scope == .broadcast {
                    path = FirebasePaths.locationBroadcasters(uid: (Auth.auth().currentUser?.uid)!)
                }
                else {
                    path = FirebasePaths.locationReceivers(uid: (Auth.auth().currentUser?.uid)!)
                }
                self!.dbRef.child(path).removeValue(completionBlock: { [weak self](error, ref) in
                    if let error = error {
                        print(error)
                        Utils.displayAlert(with: self!, title: "Sorry!", message: "Server could not be reached.", text: "OK")
                    }
                    else {
                        // remove user
                        if self!.isFiltering() {
                            self!.filteredUsers.remove(at: indexPath.row)
                        } else {
                            self!.users.remove(at: indexPath.row)
                        }
                        if scope == .broadcast {
                            self!.broadcastingUsers.remove(at: indexPath.row)
                        }
                        else {
                            self!.receivingUsers.remove(at: indexPath.row)
                        }
                        self!.tableView.beginUpdates()
                        self!.tableView.deleteRows(at: [indexPath], with: .left)
                        self!.tableView.endUpdates()
                    }
                })
            })
        }
        blockAction.image = UIImage.fontAwesomeIcon(name: .minus, textColor: .red, size: CGSize(width: 30, height: 30))
        blockAction.backgroundColor = .lightTeal
        return [blockAction]
    }
    
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
        options.backgroundColor = .teal
        return options
    }
    
    
}
