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
            
            self.title = "Request ride"
            
            //Manage driver photo
            photo.image = driver.photo
            photo.layer.masksToBounds = false
            photo.layer.cornerRadius = photo.frame.height/2
            photo.clipsToBounds = true
            name.text = driver.name
            
            totalTripTime.adjustsFontSizeToFitWidth = true
            totalTripTime.text = "\(SharingCenter.sharedInstance.tripTime!)"
            
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
            let update = GMSCameraUpdate.fit(bounds, withPadding: self.mapView.frame.width/5)
            self.mapView.moveCamera(update)
            
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "driverProfileSegue"{
                let destination = segue.destination as! UserProfileViewController
                destination.title = driver.name!
                destination.photoImage = driver.photo!
                destination.locationText = driver.mutualFriends!
                destination.aboutMeText = driver.aboutMe!
                destination.educationText = driver.education!
            }
        }
    
    @IBAction func pressedRequest(_ sender: AnyObject) {
        
        //Check if the rider has a credit card on file
        if SharingCenter.sharedInstance.customerToken == nil{
            let alertString = "You must have a credit card on file before you can request rides. You can add one via the payments section in the main menu."
            let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        //Otherwise let the request go through
        }else{
            YokweHelper.driverSelection(driver.userID!, addedTime: String(driver.addedTime!), price: driver.price!)
            
            let alertString = "You will be alerted when \(driver.name!) responds to your request"
            let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                self.returnToHomeScreen()
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewController(animated: true)
    }
        
}

