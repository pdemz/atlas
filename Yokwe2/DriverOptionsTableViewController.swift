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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let driverIndex = tableView.indexPathForSelectedRow!.row
        let nextController = segue.destination as! ConfirmationViewController
        nextController.driver = drivers[driverIndex]
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = "Select driver"
        
        populateRows()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Select driver"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    //Get list of drivers
    func populateRows(){
        YokweHelper.getDriverList{(result) -> Void in
            
            //If there are none available, present an alert
            if result.count == 0{
                DispatchQueue.main.async(execute: {
                    let alertString = "No drivers heading your way right now. We'll let you know when one becomes available!"
                    let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
                    let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                        self.returnToHomeScreen()
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                })
                
            //If there are drivers, add their FB info, then reload the data in the tableview to show the drivers
            }else{
                
                self.driverList = result
                DispatchQueue.main.async(execute: {
                    for (index,driver) in self.driverList!.enumerated(){
                        FacebookHelper.driverGraphRequest(driver, completion: {(result) -> Void in
                            let newDriver = result
                            DispatchQueue.main.async(execute: {
                                self.drivers.append(newDriver)
                                
                                if index == self.driverList!.count-1 || self.driverList == nil{
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
        if driverList == nil{
            return 0
        }else{
            return drivers.count
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
        
        if drivers.count > tableView.numberOfRows(inSection: 0){
            tableView.reloadData()
            print("reloaded")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DriverTableViewCell", for: indexPath) as! DriverTableViewCell
        cell.alpha = 0
        
        if indexPath.row < drivers.count{
            let driver = drivers[indexPath.row]
            
            cell.name.text = driver.name
            cell.photo.image = driver.photo
            cell.mutualFriends.text = "\(driver.mutualFriends!) mutual friends"
            
            //Format price
            let priceNumber = ((Double(driver.price!)!/100)) as NSNumber
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            let finalPrice = formatter.string(from: priceNumber)// "123.44$"
            
            cell.price.text = finalPrice
        }
        
        return cell
        
    }
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewController(animated: true)
    }

}
