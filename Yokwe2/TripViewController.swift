//
//  TripViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/26/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps

class TripViewController: UIViewController, TripDetailsDelegate, CLLocationManagerDelegate {
    
    //Create a trip class and put it here dang it!
    var status = "waiting"
    var driver:Driver?
    var rider:Rider?
    var totalTripTime:Double?
    var type:String? //ride or drive
    var currentDestination:String?
    var containerVC:TripDetails?
    
    //Booleans to make sure notification actions are only completed one time
    var completedPickUp = false
    var notifiedOfPickup = false
    var notifiedOfDropoff = false

    @IBOutlet weak var statusBar: UILabel!
    @IBOutlet weak var startTripButton: UIButton!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var endTripButton: UIButton!
    @IBOutlet weak var pickUp: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerBottomm: NSLayoutConstraint!
    @IBOutlet weak var pickUpButtonWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Button button who's got the button...
        pickUp.titleLabel?.adjustsFontSizeToFitWidth = true
        self.pickUp.enabled = false
        self.pickUp.hidden = true
        pickUpButtonWidth.constant -= self.view.bounds.width
        pickUp.alpha = 0
        endTripButton.alpha = 0
        endTripButton.enabled = false
        endTripButton.hidden = true
        
        //Google map view set up
        self.mapView!.myLocationEnabled = true
        self.mapView!.settings.myLocationButton = true
        
        if type! == "riding"{
            self.title = "Riding"
            
            //Mapview padding
            let mapInsets = UIEdgeInsetsMake((self.statusBar.frame.height + 8), 0, (self.detailsContainer.frame.height + 8), 0)
            self.mapView.padding = mapInsets
            
            
            statusBar.adjustsFontSizeToFitWidth = true
            
            updateDriverStatus()
            
            containerVC?.name.text = driver!.name
            containerVC?.photo.image = driver!.photo
            
            currentDestination = rider?.destination
            containerVC?.addedTime.hidden = true
            containerVC?.phoneText = driver!.phone
        }else{
            self.title = "Driving"
            
            //Hide the status bar
            statusBar.alpha = 0
            
            //Mapview padding
            let mapInsets = UIEdgeInsetsMake(0, 0, (self.detailsContainer.frame.height + 8), 0)
            self.mapView.padding = mapInsets
            
            pickUp.setTitle("Tap here once you've picked \(rider!.name!) up", forState: .Normal)
            
            if status == "waiting"{
                startTripButton.alpha = 1
                startTripButton.enabled = true
            }else{
                startTripButton.alpha = 0
                startTripButton.enabled = false
            }
            
            containerVC?.name.text = rider!.name
            containerVC?.photo.image = rider!.photo
            containerVC?.phoneText = rider!.phone
            
            currentDestination = rider?.origin
            let hours = Int((driver?.addedTime!)!/60)
            let mins = Int((driver?.addedTime!)!)
            
            containerVC?.addedTime.text = "+\(mins) mins"
            
            //Handle location updates
            SharingCenter.sharedInstance.locationManager?.delegate = self
            SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
            SharingCenter.sharedInstance.locationManager?.allowsBackgroundLocationUpdates = true
            SharingCenter.sharedInstance.locationManager?.activityType = CLActivityType.AutomotiveNavigation
            SharingCenter.sharedInstance.locationManager?.pausesLocationUpdatesAutomatically = true
            
            if status != "waiting"{
                SharingCenter.sharedInstance.locationManager?.startUpdatingLocation()
            }
            
            //Do this real quick when the view loads
            enableButtonsBasedOnLocation()
            
        }
        
        containerVC?.price.text = "$\(driver!.price!)"
        
        loadMapView()
        
        //Initialize position of details view controller
        //containerBottomm.constant -= ((containerVC?.photo.frame.height)! + 16)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        containerVC = segue.destinationViewController as? TripDetails
        containerVC?.delegate = self
        
    }
    
    func slideDetailView(){
        //Change constraint
        if self.containerBottomm.constant < 0{
            self.containerBottomm.constant += ((self.containerVC?.photo.frame.height)! + 16)
        }else{
            self.containerBottomm.constant -= ((self.containerVC?.photo.frame.height)! + 16)
        }
        
        //Now animate
        UIView.animateWithDuration(0.2){
            self.view.layoutIfNeeded()
        }
        
    }
    
    func loadMapView(){
        //let newPath = GMSPath(fromEncodedPath: SharingCenter.sharedInstance.myPath!)
        
        
        //Split rider origin and destination
        
        let riderOriginSplit = rider!.origin!.componentsSeparatedByString(",")
        let riderDestinationSplit = rider!.destination!.componentsSeparatedByString(",")
        let riderOrigin = CLLocationCoordinate2D(latitude: CLLocationDegrees((riderOriginSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((riderOriginSplit[1] as NSString).doubleValue))
        let riderDestination = CLLocationCoordinate2D(latitude: CLLocationDegrees((riderDestinationSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((riderDestinationSplit[1] as NSString).doubleValue))
        
        let riderStartMarker = GMSMarker(position: riderOrigin)
        let riderEndMarker = GMSMarker(position: riderDestination)
        riderStartMarker.title = "Start"
        riderEndMarker.title = "End"
        
        let bounds = GMSCoordinateBounds(coordinate: riderOrigin, coordinate: riderDestination)
        let update = GMSCameraUpdate.fitBounds(bounds, withPadding: self.mapView.frame.width/6)
        self.mapView.moveCamera(update)
        
        if(type! != "riding"){
            let driverOriginSplit = driver!.origin!.componentsSeparatedByString(",")
            let driverDestinationSplit = driver!.destination!.componentsSeparatedByString(",")
            let driverOrigin = CLLocationCoordinate2D(latitude: CLLocationDegrees((driverOriginSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((driverOriginSplit[1] as NSString).doubleValue))
            let driverDestination = CLLocationCoordinate2D(latitude: CLLocationDegrees((driverDestinationSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((driverDestinationSplit[1] as NSString).doubleValue))
            
            let driverStartMarker = GMSMarker(position: driverOrigin)
            driverStartMarker.map = mapView
            driverStartMarker.title = "Start"
            
            let driverEndMarker = GMSMarker(position: driverDestination)
            driverEndMarker.title = "End"
            driverEndMarker.map = mapView
            
            riderStartMarker.title = "Rider Start"
            riderEndMarker.title = "Rider End"
            
            let bounds = GMSCoordinateBounds(coordinate: driverOrigin, coordinate: driverDestination)
            let update = GMSCameraUpdate.fitBounds(bounds, withPadding: self.mapView.frame.width/6)
            self.mapView.moveCamera(update)
            
            let mh = MapsHelper()
            mh.start = self.driver?.origin
            mh.end = self.driver?.destination
            mh.rstart = self.rider?.origin
            mh.rend = self.rider?.destination
            
            mh.makeDirectionsRequest({(result) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    SharingCenter.sharedInstance.myPath = result
                    
                    
                    self.containerVC?.totalTime.text = "\(mh.duration!) total"
                    let newPath = GMSPath(fromEncodedPath: result)
                    let polyLine = GMSPolyline(path: newPath)
                    polyLine.strokeWidth = 5
                    polyLine.strokeColor = colorHelper.blue
                    polyLine.map = self.mapView
                })
            })
            
        }else{
            let mh = MapsHelper()
            mh.start = self.rider?.origin
            mh.end = self.rider?.destination
            
            mh.makeDirectionsRequest({(result) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    SharingCenter.sharedInstance.myPath = result
                    let newPath = GMSPath(fromEncodedPath: result)
                    let polyLine = GMSPolyline(path: newPath)
                    polyLine.strokeWidth = 5
                    polyLine.strokeColor = colorHelper.blue
                    polyLine.map = self.mapView
                    self.containerVC?.totalTime.text = "\(mh.duration!) total"
                })
            })
        }

        
        riderStartMarker.map = mapView
        riderEndMarker.map = mapView
        
        //Generate path with maps helper
        
    }

    func pressedNavigate() {
        //Open google maps, and route to currentDestination
        let dest = self.currentDestination!.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        //Check if Google Maps is installed
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!){
            
            //Open Google Maps
            UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps-x-callback://?saddr=&daddr=" + dest + "&directionsmode=driving&x-success=yokwe://?resume=true&x-source=Yokwe")!)
            
        //Otherwise open Apple Maps
        }else{
            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?daddr=\(dest)")!)
            
        }
        
    }
    
    @IBAction func pressedPickup(sender: AnyObject) {
        
        completedPickUp = true
        status = "leg2"
        
        self.currentDestination = rider?.destination!
        self.pickUp.enabled = false
        pickUpButtonWidth.constant -= self.view.bounds.width
        
        UIView.animateWithDuration(0.5, animations: {
            self.pickUp.layer.opacity = 0
            self.view.layoutIfNeeded()
        })
        
        //Notify server that rider has been picked up
        YokweHelper.pickUp((self.rider?.userID)!)
        
    }
    
    //Cancels the trip - no charge is made. Exactly like end trip otherwise
    func pressedCancel() {
        
        //Confirm that driver is ready to end the trip
        let alertString = "This will end the trip early, so no charge will be made. Are you sure about this?"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {(ACTION) in
            
            //Send message to server to end trip and return to homescreen
            YokweHelper.cancelTrip((self.rider?.userID)!, driverID: (self.driver?.userID)!)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //Starts the trip, alerts the rider about what is going on and starts sending location data to server
    @IBAction func startTrip(sender: AnyObject) {
        
        status = "leg1"
        SharingCenter.sharedInstance.locationManager?.startUpdatingLocation()
        YokweHelper.startTrip((self.rider?.userID)!)
        
        //Handle button animation
        self.startTripButton.enabled = false
        self.startTripButton.frame.offsetInPlace(dx: 0, dy: -(startTripButton.frame.height))
        UIView.animateWithDuration(0.5, animations: {
            self.startTripButton.frame.offsetInPlace(dx: 0, dy: -(self.startTripButton.frame.height))
            self.startTripButton.layer.opacity = 0
            self.view.layoutIfNeeded()
        })
    }
    
    //Completes the trip and charges the rider
    @IBAction func endTrip(){
        
        //Confirm that driver is ready to end the trip
        let alertString = "This will end the trip and you will be paid $\(driver!.price!)"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
            
            //Send message to server to end trip and return to homescreen
            YokweHelper.endTrip((self.rider?.userID)!, driverID: (self.driver?.userID)!)
            
            //Stop updating location
            SharingCenter.sharedInstance.locationManager?.stopUpdatingLocation()
            
            //Dismiss the view controller
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.Default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateDriverStatus(){
        //Update status bar appropriately
        if status == "leg2"{
            containerVC?.cancel.alpha = 0
            containerVC?.cancel.enabled = false
            
            statusBar.alpha = 0
            
        }else if status == "leg1"{
            statusBar.textColor = colorHelper.orange
            statusBar.text = "\((driver?.name)!) is en route"
            
        }else{
            statusBar.textColor = UIColor.orangeColor()
            statusBar.text = "Waiting for \((driver?.name)!) to start the trip."
        }
    }
    
    func tappedPhoto() {
        //Present profile with phone number
        presentProfile()
        
    }
    
    func presentProfile(){
        var selfProfile = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController
        selfProfile = customizeVC(selfProfile) as! UserProfileViewController
        
        //Get driver info
        if self.type! == "riding"{
            selfProfile.title = self.driver?.name
            selfProfile.photoImage = self.driver?.photo
            selfProfile.phoneText = self.driver?.phone
            selfProfile.aboutMeText = self.driver?.aboutMe
            selfProfile.locationText = self.driver?.mutualFriends
            selfProfile.educationText = self.driver?.education
            
            //else get rider info
        }else{
            selfProfile.title = self.rider?.name
            selfProfile.photoImage = self.rider?.photo
            selfProfile.phoneText = self.rider?.phone
            selfProfile.aboutMeText = self.rider?.aboutMe
            selfProfile.locationText = self.rider?.mutualFriends
            selfProfile.educationText = self.rider?.education


        }
        
        
        var navController = UINavigationController(rootViewController: selfProfile)
        navController = customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        return navController
    }
    
    func customizeVC(vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: vc, action: "closeView")
        vc.navigationItem.leftBarButtonItem = dismissButton
        
        return vc
    }

    func tappedBackground(){
        slideDetailView()
    }
    
    func enableButtonsBasedOnLocation(){
        if type! != "riding"{
            SharingCenter.sharedInstance.locationManager?.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("failed to update location :(")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("driver location updated!")
        
        //Get current location
        let driverLocation = SharingCenter.sharedInstance.locationManager?.location!
        
        //Get the CLLocation from coordinates
        let latLongPickUp = self.rider!.origin!.componentsSeparatedByString(",")
        let latLongDropOff = self.rider!.destination!.componentsSeparatedByString(",")
        
        let pickup = CLLocation(latitude: CLLocationDegrees(latLongPickUp[0])!, longitude: CLLocationDegrees(latLongPickUp[1])!)
        let dropOff = CLLocation(latitude: CLLocationDegrees(latLongDropOff[0])!, longitude: CLLocationDegrees(latLongDropOff[1])!)
        
        //Get distance
        let distanceInMetersFromPickup = driverLocation!.distanceFromLocation(pickup)
        let distanceInMetersFromDropoff = driverLocation!.distanceFromLocation(dropOff)
        
        print("distance from pickup in meters: \(distanceInMetersFromPickup)")
        print("distance from dropoff in meters: \(distanceInMetersFromDropoff)")
        
        //Check if they are within about 1 mile of pickup point
        if distanceInMetersFromPickup < 1000 && status == "leg1"{
            
            //Local notification that they need to select that they picked up the passenger.
            if notifiedOfPickup == false{
                let notification = UILocalNotification()
                notification.alertBody = "You must confirm in the app once you've picked \(rider!.name!) up"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                
                notifiedOfPickup = true
            }
            
            //show pickup button
            self.pickUp.enabled = true
            self.pickUp.hidden = false
            pickUpButtonWidth.constant += self.view.bounds.width
            //Now animate
            UIView.animateWithDuration(0.5){
                self.pickUp.alpha = 0.9
                self.view.layoutIfNeeded()
            }
            
        //Check if they are within about 1 mile of drop off point and rider has been picked up.
        }else if distanceInMetersFromDropoff < 1000 && self.pickUp.enabled == false && status == "leg2"{
            
            //Local notification that they can drop off passenger and end trip
            if notifiedOfDropoff == false{
                print("Got into drop off")
                let notification = UILocalNotification()
                notification.alertBody = "You can now end the trip once you drop \(rider!.name!) off"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().presentLocalNotificationNow(notification)
                
                notifiedOfDropoff = true
            }
            
            //show end trip button
            self.endTripButton.enabled = true
            self.endTripButton.hidden = false
            pickUpButtonWidth.constant += self.view.bounds.width
            
            //Now animate
            UIView.animateWithDuration(0.5){
                self.endTripButton.alpha = 0.9
                self.view.layoutIfNeeded()
            }
            
        }

    }

}
