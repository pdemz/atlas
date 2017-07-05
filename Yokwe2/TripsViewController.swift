//
//  TripsViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/2/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class TripsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var rideRequestsTableView: UITableView!
    @IBOutlet weak var driveOffersTableView: UITableView!
    
    var driveTrips = [TripStatusObject]()
    var rideTrips = [TripStatusObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        print("Got as far as this.")
        
        rideRequestsTableView.delegate = self
        driveOffersTableView.delegate = self
        
        rideRequestsTableView.dataSource = self
        driveOffersTableView.dataSource = self
        
        rideRequestsTableView.allowsSelection = false
        driveOffersTableView.allowsSelection = false
        
        getTrips()
        
    }
    
    func getTrips(){
        YokweHelper.getActiveTrips{(result) in
            self.rideTrips = result[0]
            self.driveTrips = result[1]
            
            DispatchQueue.main.async(execute: {
                self.rideRequestsTableView.reloadData()
                self.driveOffersTableView.reloadData()
                
            })
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == rideRequestsTableView{
            return rideTrips.count
            
        }else{
            return driveTrips.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == driveOffersTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsDriveTableViewCell", for: indexPath) as! TripsTableViewCell
            
            cell.from.text = driveTrips[indexPath.row].from!
            cell.to.text = driveTrips[indexPath.row].to!
            cell.status.text = driveTrips[indexPath.row].status!
            cell.isActive = driveTrips[indexPath.row].isActive
    
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TripsTableViewCell", for: indexPath) as! TripsTableViewCell
            
            cell.from.text = rideTrips[indexPath.row].from!
            cell.to.text = rideTrips[indexPath.row].to!
            cell.status.text = rideTrips[indexPath.row].status!
            cell.isActive = rideTrips[indexPath.row].isActive
            
            return cell
        }
        
    }
    
    
}
