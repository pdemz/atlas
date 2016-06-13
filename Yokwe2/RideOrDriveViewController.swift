//
//  RideOrDriveViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 6/6/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

class RideOrDriveViewController: UIViewController {
    @IBAction func ride(sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "rider"
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func drive(sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "driver"
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}
