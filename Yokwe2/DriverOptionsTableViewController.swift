//
//  DriverOptionsTablewViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/4/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit

class DriverOptionsTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var drivers = [Driver]()
    var driverList:[Driver]?
    let myBool = true
    
    
    @IBOutlet weak var indicatorr: UIActivityIndicatorView!
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let driverIndex = tableView.indexPathForSelectedRow!.row
        let nextController = segue.destinationViewController as! ConfirmationViewController
        nextController.driver = drivers[driverIndex]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Select driver"
        
        populateRows()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Select driver"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    func populateRows(){
        YokweHelper.getDriverList{(result) -> Void in
            if result.count == 0{
                dispatch_async(dispatch_get_main_queue(), {
                    let alertString = "No drivers heading your way right now. We'll let you know when one becomes available!"
                    let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                        self.returnToHomeScreen()
                    })
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }else{
                
                self.driverList = result
                dispatch_async(dispatch_get_main_queue(), {
                    for (index,driver) in self.driverList!.enumerate(){
                        FacebookHelper.driverGraphRequest(driver, completion: {(result) -> Void in
                            let newDriver = result
                            dispatch_async(dispatch_get_main_queue(), {
                                self.drivers.append(newDriver)
                                if index == self.driverList!.count-1 || self.driverList == nil{
                                    self.tableView.reloadData()
                                    self.indicatorr.stopAnimating()
                                    UIView.animateWithDuration(0.5, animations: {
                                        self.indicatorr.frame.offsetInPlace(dx: 0, dy: 20)
                                        self.indicatorr.alpha = 0
                                    })
                                }
                            })
                        })
                    }
                })
                
            }
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if driverList == nil{
            return 0
        }else{
            return drivers.count
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.alpha = 0
        cell.frame.offsetInPlace(dx: 0, dy: 20)
        
        UIView.animateWithDuration(0.5, animations: {
            cell.alpha = 1
            cell.frame.offsetInPlace(dx: 0, dy: -20)
        })
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if drivers.count > tableView.numberOfRowsInSection(0){
            tableView.reloadData()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DriverTableViewCell", forIndexPath: indexPath) as! DriverTableViewCell
        cell.alpha = 0
        
        if indexPath.row < drivers.count{
            //let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            let driver = drivers[indexPath.row]
            
            cell.name.text = driver.name
            cell.photo.image = driver.photo
            cell.mutualFriends.text = "\(driver.mutualFriends!) mutual friends"
            cell.price.text = ("$\(Double(driver.price!)!/100)")
        }
        
        return cell
        
    }
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewControllerAnimated(true)
    }

}
