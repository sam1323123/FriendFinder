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
    
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    fileprivate var searchBar: UISearchBar?  //searchBar associated with searchController
    
    private let testData = [("Title 1", "Subtitle 1"), ("Title 2", "Subtitle 2")]
    
    private var filteredTableData = [(String, String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate  = self
        searchBar = searchController.searchBar
        initSearchBar()
        filteredTableData = testData
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
        return filteredTableData.count
    }
    
    /*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
*/
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subtitleCell", for: indexPath)
        
        // Configure the cell...
        
        let (title, subtitle) = filteredTableData[indexPath.row] // row should always be < than size of array
        cell.textLabel!.text = title
        cell.detailTextLabel!.text = subtitle
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
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


    // MARK: - Navigation
    
    //perform segues here
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

    
    //configure and make search bar
    func initSearchBar() {
        //init the search Bar
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchBar
        searchBar?.delegate = self
        
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
    
    func filterSearchResults(searchString: String?) {
        if(searchString == nil) {
            //tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.left)
            return
        }
        //else filter testData
        let res = testData.filter { (s1: String, s2: String) in
            if((s1.lowercased()).contains(searchString!.lowercased())) {
                return true
            }
            return false
        }
        
        filteredTableData = res
        tableView.reloadSections(IndexSet([0]), with: UITableViewRowAnimation.left)
    }
    
}



extension LocationTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for: UISearchController) {
        if let sb = searchBar {
            filterSearchResults(searchString: sb.text)
        }
        //else do nothing
    }
    
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



