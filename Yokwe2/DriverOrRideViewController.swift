//
//  DriverOrRideViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/29/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class DriverOrRideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }

    @IBAction func driveButtonPush(sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "driver"
        performSegueWithIdentifier("modeSelectSegue", sender: sender)
    }
    
    @IBAction func rideButtonPush(sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "rider"
        performSegueWithIdentifier("modeSelectSegue", sender: sender)

    }
    
    @IBAction func logOut(sender: AnyObject) {
        let manager = FBSDKLoginManager()
        manager.logOut()
        performSegueWithIdentifier("titleSegue", sender: self)
    }
    
    
    
    
    
}
