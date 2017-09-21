//
//  TripsTableViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 8/17/17.
//  Copyright © 2017 Pierce Demarreau. All rights reserved.
//

import UIKit

class TripsTableViewController: UITableViewController, TripsCellDelegate {

    var trips = [TripStatusObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        /*
        let rideTrip1 = TripStatusObject(newTo: "Los Angeles", newFrom: "San Diego", newStatus: "Waiting for Jon to start the trip", newMode: "Ride")
        let rideTrip2 = TripStatusObject(newTo: "San Diego", newFrom: "Los Angeles", newStatus: "Waiting for a response", newMode: "Ride")
        let driveTrip1 = TripStatusObject(newTo: "Los Angeles", newFrom: "San Diego", newStatus: "Confirmed Eli Dan as your rider", newMode: "Drive")
        
        trips.append(rideTrip1)
        trips.append(rideTrip2)
        trips.append(driveTrip1)
 
        */
        
        //Get trip list from server, then load the data into the tableview
        YokweHelper.getTrips(completion: { (result) -> Void in
            DispatchQueue.main.async(execute: {
                self.trips = result
                self.tableView.reloadData()
                
            })
        })
        
    }

    //Deletes a row after the delete button has been tapped in the cell
    func didPressDeleteButton(_ tag: Int) {
        let tripID = trips[tag].tripID!
        print(tripID)
        //remove from database
        YokweHelper.deleteTrip(tripID: tripID)
        
        //remove from table
        self.trips.remove(at: tag)
        self.tableView.deleteRows(at: [IndexPath(item: tag, section: 0)], with: .automatic)
        self.tableView.reloadData()

    }
    
    
    //Should only be one section, for ride and drive requests combined
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }

    //Set number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }
    
    //Get active trips from the server
    func getTrips(){
        YokweHelper.getActiveTrips{(result) in
            self.trips = result
            
            DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                
            })
        }
    }

    //Populate the table with cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath) as! DashboardTableViewCell
        
        cell.indexPath = indexPath
        cell.cellDelegate = self
        cell.routeLabel.text = "\(trips[indexPath.row].from!) to \(trips[indexPath.row].to!)"
        cell.statusLabel.text = trips[indexPath.row].status!
        cell.modeLabel.text = trips[indexPath.row].mode!
     
        return cell
    }
    
    func closeView(){
        self.dismiss(animated: true, completion: nil)
    }

}
