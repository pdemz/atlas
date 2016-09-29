//
//  RiderOptionsTableViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/29/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit

class RiderOptionsTableViewController: UITableViewController{

    //MARK: Properties
    var riderList:[Rider]?
    var riders:[Rider]? = [Rider]()
    
    @IBOutlet weak var indicatorr: UIActivityIndicatorView!
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            let riderIndex = tableView.indexPathForSelectedRow!.row
            let nextController = segue.destinationViewController as! ConfirmRiderViewController
            nextController.rider = riders![riderIndex]
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Select rider"
        
        populateRows()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Select rider"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    func populateRows(){
        YokweHelper.getRiderList{(result) -> Void in
            
            //Alert the user that there is no one heading their way
            if result.count == 0{
                dispatch_async(dispatch_get_main_queue(), {
                    let alertString = "No riders heading your way right now. We'll let you know when one becomes available!"
                    let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                        self.returnToHomeScreen()
                    })
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                })
                
            }else{
                //Once we get the list of riders from the server...
                self.riderList = result
                dispatch_async(dispatch_get_main_queue(), {
                    //We iterate through it...
                    for (index,rider) in self.riderList!.enumerate(){
                        print("yet the index is: \(index)")
                        //Get info from FB
                        FacebookHelper.riderGraphRequest(rider, completion: {(result) -> Void in
                            let newRider = result
                            dispatch_async(dispatch_get_main_queue(), {
                                //And add each rider to a new list
                                print("Total number of riders: \(self.riders!.count)")
                                self.riders!.append(newRider)
                                
                                //Once we get to the last rider, we stop the loading process
                                if index == self.riderList!.count-1{
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
        if riderList == nil{
            return 0
        }else{
            print("rider count: \(riders!.count)")
            print("riderList count: \(riderList!.count)")
            return riders!.count
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
        let cell = tableView.dequeueReusableCellWithIdentifier("RiderOptionTableViewCell", forIndexPath: indexPath) as! RiderOptionTableViewCell
        
        if riders!.count > tableView.numberOfRowsInSection(0){
            tableView.reloadData()
        }
        
        if indexPath.row < riders!.count{
            let rider = riders![indexPath.row]
            
            cell.name.text = rider.name
            cell.addedTime.text = "+\(rider.addedTime!) min"
            cell.photo.image = rider.photo
            cell.mutualFriends.text = "\(rider.mutualFriends!) mutual friends"
            cell.price.text = ("$\(Double(rider.price!)!/100)")
        }
        return cell

    }
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
