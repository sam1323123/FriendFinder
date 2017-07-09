//
//  LocationTableTableViewController.swift
//  FriendFinder
//
//  Created by Samuel Lee on 7/9/17.
//  Copyright © 2017 Samuel Lee and Avishek Ganguli. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {

    //holds the text entry that was entered in mapViewController
    private var currentLocationEntry: String = ""
    
    private var searchBar: UISearchBar?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate  = self
        //self.initSearchBar()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    
    //configure and make search bar
    func initSearchBar() {
        //init the search Bar
        self.searchBar = UISearchBar(frame: (self.tableView.tableHeaderView?.bounds)!)
        self.tableView.tableHeaderView = self.searchBar
        self.searchBar?.delegate = self
        self.searchBar?.barStyle = UIBarStyle.default
        self.searchBar?.showsBookmarkButton = false
        self.searchBar?.showsCancelButton = true
        self.searchBar?.showsSearchResultsButton = false
        //self.searchBar?.sizeToFit() //not sure if needed
        
        
    }
    
    
    //set search bar text
    func setSearchBarEntry(entry: String) {
        if let bar = self.searchBar {
            bar.text = entry
            //might have to call searchBar did begin editing
        }
        else {
            print("Search Bar should have been intialized")
        }
    }
    
    
    
    
    //HELPER METHODS 
    
}



extension LocationTableViewController: UISearchBarDelegate {
    //SEARCH BAR METHODS AND SEARCH DELEGATE
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "" //empty search text
    }

}



