//
//  confirmRiderViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 11/2/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import GoogleMaps

class ConfirmRiderViewController: UIViewController {
    
    var rider:Rider!
    
    @IBOutlet weak var startTripButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.image = rider.photo
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        name.text = rider.name
        
        tripTimesView.layer.borderWidth = 0.3
        tripTimesView.layer.borderColor = UIColor.lightGrayColor().CGColor
        addedTime.text = "Time added: \(rider.addedTime!) mins"
        totalTripTime.text = "Total trip: \(getTotalTripTime())"
        
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Properties
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tripTimesView: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var addedTime: UILabel!
    
    var tripTimeString:String?
    @IBOutlet weak var totalTripTime: UILabel!
    
    /*
    @IBOutlet weak var fareEstimate: UILabel!
    @IBOutlet weak var startTrip: UIButton!
    @IBOutlet weak var endTrip: UIButton!
*/
    
    
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
        if segue.identifier == "profileSegue"{
            let destination = segue.destinationViewController as! UserProfileViewController
            destination.title = rider.name!
            destination.photoImage = rider.photo!
            destination.locationText = rider.mutualFriends!
        }
    }
    
    
    @IBAction func pressedOffer(sender: AnyObject) {
        YokweHelper.riderSelection(rider.userID!, addedTime: rider.addedTime!)
        
        let alertString = "You will be alerted when \(rider.name!) responds to your offer"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
            self.returnToHomeScreen()
        })
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    /*
    @IBAction func startButtonPush(sender: AnyObject) {
        if startTrip.titleLabel!.text == "Navigate"{
            endTrip.alpha = 1
            let dest = self.destination!.stringByReplacingOccurrencesOfString(" ", withString: "+")
            
            //Check if Google Maps is installed
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!){
                
                //Open Google Maps
                UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps-x-callback://?saddr=&daddr=" + dest + "&directionsmode=driving&x-success=yokwe://?resume=true&x-source=Yokwe")!)
            }
        }else if startTrip.titleLabel!.text == "Start trip"{
            rideRequest()
            startTrip.setTitle("Navigate", forState: .Normal)
        }else if startTrip.titleLabel!.text == "Accept ride request"{
            acceptRequest()
            print("Accept was pushed.")
            startTrip.setTitle("Navigate", forState: .Normal)
        }
        
        
        
        
    }
*/
    
    func returnToHomeScreen(){
        SharingCenter.sharedInstance.shouldReset = true
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func getTotalTripTime() -> String{
        let tripTimeString = SharingCenter.sharedInstance.tripTime
        let splitString = tripTimeString!.componentsSeparatedByString(" ")
        for index in 0...splitString.count{
            if splitString[index] == "mins"{
                var minNum = Int(splitString[index-1])
                minNum = minNum! + Int(rider.addedTime!)!
                if splitString.count == 2{
                    return "\(minNum!) mins"
                }else{
                    return "\(splitString[0]) \(splitString[1]) \(minNum!) mins"
                }
            }
        }
        return ""
    }

    

}
