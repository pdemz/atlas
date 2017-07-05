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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let riderIndex = tableView.indexPathForSelectedRow!.row
            let nextController = segue.destination as! ConfirmRiderViewController
            nextController.rider = riders![riderIndex]
            
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Select rider"
        
        populateRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Select rider"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    func populateRows(){
        YokweHelper.getRiderList{(result) -> Void in
            
            print("result count: \(result.count)")
            
            //Alert the user that there is no one heading their way
            if result.count == 0{
                DispatchQueue.main.async(execute: {
                    let alertString = "No riders heading your way right now. We'll let you know when one becomes available!"
                    let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                        self.returnToHomeScreen()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                })
                
            }else{
                //Once we get the list of riders from the server...
                self.riderList = result
                DispatchQueue.main.async(execute: {
                    //We iterate through it...
                    for (index,rider) in self.riderList!.enumerated(){
                        //Get info from FB
                        FacebookHelper.riderGraphRequest(rider, completion: {(result) -> Void in
                            let newRider = result
                            
                            DispatchQueue.main.async(execute: {
                                
                                //add each rider to a new list
                                print("Total number of riders: \(self.riders!.count)")
                                self.riders!.append(newRider)
                                
                                //Once we get to the last rider, we stop the loading process
                                if index == self.riderList!.count-1{
                                    self.tableView.reloadData()
                                    self.indicatorr.stopAnimating()
                                    UIView.animate(withDuration: 0.5, animations: {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if riderList == nil{
            return 0
        }else{
            print("rider count: \(riders!.count)")
            print("riderList count: \(riderList!.count)")
            return riders!.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "RiderOptionTableViewCell", for: indexPath) as! RiderOptionTableViewCell
        
        if riders!.count > tableView.numberOfRows(inSection: 0){
            tableView.reloadData()
        }
        
        if indexPath.row < riders!.count{
            let rider = riders![indexPath.row]
            
            cell.name.text = rider.name
            cell.addedTime.text = "+\(rider.addedTime!) min"
            cell.photo.image = rider.photo
            cell.mutualFriends.text = "\(rider.mutualFriends!) mutual friends"
            
            //Format the price
            let priceNumber = (Double(rider.price!)!/100) as NSNumber //123.44
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            let formattedPriceText = formatter.string(from: priceNumber)// "123.44$"
            
            cell.price.text = formattedPriceText
        }
        return cell

    }
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewController(animated: true)
    }
    
}
