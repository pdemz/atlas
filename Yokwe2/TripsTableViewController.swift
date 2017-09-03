//
//  TripsTableViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 8/17/17.
//  Copyright © 2017 Pierce Demarreau. All rights reserved.
//

import UIKit

class TripsTableViewController: UITableViewController {

    var driveTrips = [TripStatusObject]()
    var rideTrips = [TripStatusObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getTrips()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    //Should only be one section, for ride and drive requests combined
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    //Set number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return driveTrips.count + rideTrips.count
    }
    
    //Get active trips from the server
    func getTrips(){
        YokweHelper.getActiveTrips{(result) in
            self.rideTrips = result[0]
            self.driveTrips = result[1]
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                
            })
        }
    }

    //Populate the table with cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripsDriveTableViewCell", for: indexPath) as! TripsTableViewCell
     
        cell.from.text = driveTrips[indexPath.row].from!
        cell.to.text = driveTrips[indexPath.row].to!
        cell.status.text = driveTrips[indexPath.row].status!
        cell.isActive = driveTrips[indexPath.row].isActive
     
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
