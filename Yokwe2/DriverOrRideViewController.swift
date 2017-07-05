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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    @IBAction func driveButtonPush(_ sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "driver"
        performSegue(withIdentifier: "modeSelectSegue", sender: sender)
    }
    
    @IBAction func rideButtonPush(_ sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "rider"
        performSegue(withIdentifier: "modeSelectSegue", sender: sender)

    }
    
    @IBAction func logOut(_ sender: AnyObject) {
        let manager = FBSDKLoginManager()
        manager.logOut()
        performSegue(withIdentifier: "titleSegue", sender: self)
    }
    
    
    
    
    
}
