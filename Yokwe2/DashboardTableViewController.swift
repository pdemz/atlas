//
//  DashboardTableViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/22/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class DashboardTableViewController: UITableViewController {
    //MARK: Properties
    var requestList:[String]?
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let riderIndex = tableView.indexPathForSelectedRow!.row
        let nextController = segue.destination as! ConfirmRiderViewController
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Dashboard"

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requestList == nil{
            return 0
        }else{
            return requestList!.count
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.frame.offsetInPlace(dx: 0, dy: 20)
        
        UIView.animate(withDuration: 0.5, animations: {
            cell.alpha = 1
            cell.frame.offsetInPlace(dx: 0, dy: -20)
        })
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardTableViewCell", for: indexPath) as! DashboardTableViewCell
        
        //let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let request = requestList![indexPath.row]
        
        
        //cell.name = rider.name
        //cell.addedTime.text = "+\(rider.addedTime!) min"
        //cell.photo.image = rider.photo
        
        return cell
        
    }
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewController(animated: true)
    }
    
}

extension CGRect {
    mutating func offsetInPlace(dx: CGFloat, dy: CGFloat) {
        self = self.offsetBy(dx: dx, dy: dy)
    }
}
