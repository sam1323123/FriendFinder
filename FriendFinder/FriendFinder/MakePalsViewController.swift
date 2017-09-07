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

infix operator ||=
func ||=(lhs: inout Bool, rhs: Bool) { lhs = (lhs || rhs) }

class MakePalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var searchFooter: SearchFooter!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate let dbRef = Database.database().reference()
    private let storageRef = Storage.storage().reference()
    
    private var users = [FFUser]()
    private var usernames: [String]!
    private var nameMap = [String:String]()
    private var iconMap = [String:UIImage]()
    
    private var filteredUsers = [FFUser]()
    private var sentUsernames = [String]()
    
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    private var timer: Timer?
    
    enum Scope: String {
        case all
        case username
        case name
    }
    
    let scopeMap: [String:Scope] = ["All": .all, "Username": .username, "Name": .name]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["All", "Name", "Username"]
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        // Setup the search footer
        tableView.tableFooterView = searchFooter
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.backBarButtonItem?.title = String.fontAwesomeIcon(name: .chevronLeft)
        initData()
        filterData()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.visibleViewController?.present(SideMenuManager.menuLeftNavigationController!, animated: true)
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
        let usernameMatch = (scope == .all) || (scope == .username)
        let nameMatch = (scope == .all) || (scope == .name)
        filteredUsers = users.filter({( user : FFUser) -> Bool in
            var filter = false
            if (nameMatch) {
                filter ||= user.name.lowercased().contains(searchText.lowercased())
            }
            if (usernameMatch) {
                filter ||= user.username.lowercased().contains(searchText.lowercased())
            }
            return filter
        })
        
        tableView.reloadData()
    }
    
    fileprivate func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    private func initData() {
        dbRef.child("usernames").observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
            let data = snapshot.value as! [String:AnyObject]
            // remove self from other users
            /*if let index = self!.usernames.index(of: MapViewController.currentController!.userName!) {
             self!.usernames.remove(at: index)
             }*/
            self!.usernames = Array(data.keys)
            for username in self!.usernames {
                self!.nameMap[username] = (((data[username] as! [String:AnyObject])["name"])! as! String)
                self!.storageRef.child(FirebasePaths.userIcons(username: username)).getData(maxSize: 1 * 1024 * 1024) { data, error in
                    let image: UIImage
                    if let error = error {
                        // Uh-oh, an error occurred!
                        print(error)
                        image = #imageLiteral(resourceName: "no_image")
                    } else {
                        image = UIImage(data: data!)!
                    }
                    self?.iconMap[username] = image
                    self?.users.append(FFUser(name: self!.nameMap[username]!, username: username, picture: image))
                }
            }
            self?.spinner.center = self!.tableView.center
            self?.tableView.addSubview(self!.spinner)
            self?.tableView.bringSubview(toFront: self!.spinner)
            self?.spinner.startAnimating()
            self?.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self!, selector: #selector(self?.checkDone), userInfo: nil, repeats: true)
        })
    }
    
    private func filterData()  {
        if sentUsernames.isEmpty {
            dbRef.child(FirebasePaths.connectionRequested(uid: (Auth.auth().currentUser?.uid)!)).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                if snapshot.exists() {
                    let data = snapshot.value as! [String:String]
                    self!.sentUsernames = Array(data.keys)
                }
            })
        }
    }
    
    func checkDone() {
        if (users.count == usernames.count) {
            timer?.invalidate()
            spinner.stopAnimating()
            tableView.reloadData()
        }
    }

    func onButtonClick(sender: UserSelectionButton) {
        print("clicked!")
        if (sender.titleLabel?.text == String.fontAwesomeIcon(name: .plus)) {
            requestConnection(user: sender.user!)
            sentUsernames.append(sender.user!.username)
            tableView.reloadData()
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
        let user: FFUser
        if isFiltering() {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        userCell.nameLabel.text = user.name
        userCell.usernameLabel.text = user.username
        userCell.userIcon.image = user.picture
        userCell.userButton.user = user
        if sentUsernames.contains(user.username) {
            userCell.userButton.titleLabel?.font = UIFont(name: "Bodoni 72", size: (userCell.userButton.titleLabel?.font.pointSize)!)?.setBold()
            userCell.userButton.setTitle("Pending", for: .normal)
            userCell.userButton.removeTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
        }
        else {
            userCell.userButton.addTarget(self, action: #selector(onButtonClick(sender:)), for: .touchUpInside)
            userCell.userButton.setTitle(String.fontAwesomeIcon(name: .plus), for: .normal)
        }
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


extension MakePalsViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = scopeMap[searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]]!
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

extension MakePalsViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scope = scopeMap[searchBar.scopeButtonTitles![selectedScope]]!
        filterContentForSearchText(searchBar.text!, scope: scope)
    }
}

//extension for connecting to friend
extension MakePalsViewController {
    
    //perfomrs write to connectionRequest table of target user
    func writeToConnectionRequest(targetUid: String, myUsername: String, myName: String) {
        dbRef.child(FirebasePaths.connectionRequests(uid: targetUid)).updateChildValues([myUsername: myName], withCompletionBlock: {(err, ref) in
            if let err = err {
                print("Failed to make connection due to \(err)")
                Utils.displayAlert(with: self, title: "Make Pal Failed", message: "Cannot request for connection due to: \(err)", text: "OK")
            }
            else {
                //TODO show some change to reflect connection added
                return
            }
        })
    }
    
    func requestConnection(user: FFUser) {
        let username = user.username
        let ownNames = UserDefaults.standard.dictionaryWithValues(forKeys: ["username", "name"])
        let (un, name) = (ownNames["username"] as? String, ownNames["name"] as? String)
        guard let myUsername = un, let myPreferredName = name else {
            return //cannot make connection
        }
        dbRef.child(FirebasePaths.connectionRequested(uid: (Auth.auth().currentUser?.uid)!)).updateChildValues([username : user.name]) {[weak self] (err, ref) in
            if let err = err {
                print("Failed to make connection due to \(err)")
                Utils.displayAlert(with: self!, title: "Make Pal Failed", message: "Cannot request for connection due to: \(err)", text: "OK")
            }
            else {
                self?.dbRef.child(FirebasePaths.usernameProfileUid(username: username)).observeSingleEvent(of: .value, with: {[weak self] (snapshot) in
                    if(snapshot.exists()) {
                        self?.writeToConnectionRequest(targetUid: snapshot.value as! String, myUsername: myUsername, myName: myPreferredName)
                    }
                    else {
                        print("Should not happen in requestConnection")
                    }
                    }, withCancel: {(err) in
                        print("Failed to make connection due to \(err)")
                        Utils.displayAlert(with: self!, title: "Make Pal Failed", message: "Cannot request for connection due to: \(err)", text: "OK")
                })
            }
        }
    }
}
