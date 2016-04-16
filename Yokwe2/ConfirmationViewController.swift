//
//  ConfirmationViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/14/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleMaps

class ConfirmationViewController: UIViewController {
    
        var driver:Driver!
    
        @IBOutlet weak var startTripButton: UIButton!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            photo.image = driver.photo
            photo.layer.masksToBounds = false
            photo.layer.cornerRadius = photo.frame.height/2
            photo.clipsToBounds = true
            name.text = driver.name
            totalTripTime.text = "Trip duration: \(SharingCenter.sharedInstance.tripTime!)"
            
            loadMapView()
            
            /*
            fareEstimate.text = "+\(addedTime!) min."
            startTrip.setTitle(buttonTitle, forState: .Normal)
            startTrip.alpha = 1
            
            if startTrip.titleLabel!.text == "Accept ride request"{
            endTrip.alpha = 1
            endTrip.setTitle("Reject", forState: .Normal)
            }else{
            endTrip.alpha = 0
            }
            */
            
        }
    
        @IBOutlet weak var totalTripTime: UILabel!
        @IBOutlet weak var mapView: GMSMapView!
        @IBOutlet weak var tripTimesView: UIView!
        @IBOutlet weak var photo: UIImageView!
        @IBOutlet weak var name: UILabel!
        
        func loadMapView(){
            let newPath = GMSPath(fromEncodedPath: SharingCenter.sharedInstance.myPath!)
            let startMarker = GMSMarker(position: SharingCenter.sharedInstance.startLocation!)
            startMarker.map = mapView
            startMarker.title = "Start"
            let endMarker = GMSMarker(position: SharingCenter.sharedInstance.endLocation!)
            endMarker.title = "End"
            endMarker.map = mapView
            let polyLine = GMSPolyline(path: newPath)
            polyLine.map = self.mapView
            polyLine.strokeWidth = 5
            polyLine.strokeColor = colorHelper.blue
            let bounds = GMSCoordinateBounds(path: newPath!)
            let update = GMSCameraUpdate.fitBounds(bounds, withPadding: self.mapView.frame.width/5)
            self.mapView.moveCamera(update)
            
        }
        
        override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "driverProfileSegue"{
                let destination = segue.destinationViewController as! UserProfileViewController
                destination.title = driver.name!
                destination.photoImage = driver.photo!
                destination.locationText = driver.mutualFriends!
            }
        }
    
    @IBAction func pressedRequest(sender: AnyObject) {
        print("This is being stored: \(String(driver.addedTime!))")
        YokweHelper.driverSelection(driver.userID!, addedTime: String(driver.addedTime!), price: driver.price!)
        
        let alertString = "You will be alerted when \(driver.name!) responds to your request"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
            self.returnToHomeScreen()
        })
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
        
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewControllerAnimated(true)
    }
        
}

