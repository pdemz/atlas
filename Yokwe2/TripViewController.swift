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

    @IBOutlet weak var driverStatusViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var driverWaypointLabel: UILabel!
    @IBOutlet weak var driverInstructionLabel: UILabel!
    @IBOutlet weak var driverStatusView: UIView!
    
    @IBOutlet weak var statusBar: UILabel!
    @IBOutlet weak var startTripButton: UIButton!
    @IBOutlet weak var detailsContainer: UIView!
    @IBOutlet weak var endTripButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var containerBottomm: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Button button who's got the button...
        endTripButton.alpha = 0
        endTripButton.isEnabled = false
        endTripButton.isHidden = true
        endTripButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        startTripButton.titleLabel?.text
        startTripButton.titleLabel?.adjustsFontSizeToFitWidth
        
        //Google map view set up
        self.mapView!.isMyLocationEnabled = true
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
            containerVC?.addedTime.isHidden = true
            containerVC?.phoneText = driver!.phone
        }else{
            self.title = "Driving"
            
            //initialize driver status view
            driverInstructionLabel.text = "Pick \(rider!.name!) up at"
            driverWaypointLabel.text = "\(rider!.originAddress!)"
            driverInstructionLabel.adjustsFontSizeToFitWidth = true
            driverWaypointLabel.adjustsFontSizeToFitWidth = true
            slideDriverStatusView()
            
            
            //Hide the status bar
            statusBar.alpha = 0
            
            //Mapview padding
            let mapInsets = UIEdgeInsetsMake(0, 0, (self.detailsContainer.frame.height + 8), 0)
            self.mapView.padding = mapInsets
            
            if status == "waiting"{
                slideDriverStatusView()
                startTripButton.alpha = 1
                startTripButton.isEnabled = true
            }else{
                startTripButton.alpha = 0
                startTripButton.isEnabled = false
            }
            
            containerVC?.name.text = rider!.name
            containerVC?.photo.image = rider!.photo
            containerVC?.phoneText = rider!.phone
            
            currentDestination = rider?.origin
            
            containerVC?.addedTime.text = "+\(Int(driver!.addedTime!)) mins"
            
            //Handle location updates
            SharingCenter.sharedInstance.locationManager?.delegate = self as! CLLocationManagerDelegate
            SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
            SharingCenter.sharedInstance.locationManager?.allowsBackgroundLocationUpdates = true
            SharingCenter.sharedInstance.locationManager?.activityType = CLActivityType.automotiveNavigation
            SharingCenter.sharedInstance.locationManager?.pausesLocationUpdatesAutomatically = true
            
            if status != "waiting"{
                SharingCenter.sharedInstance.locationManager?.startUpdatingLocation()
            }
            
            //Do this real quick when the view loads
            enableButtonsBasedOnLocation()
            
        }
        
        containerVC?.price.text = driver!.price!
        
        loadMapView()
        
        //Initialize position of details view controller
        //containerBottomm.constant -= ((containerVC?.photo.frame.height)! + 16)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        containerVC = segue.destination as? TripDetails
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
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
        
    }
    
    func slideDriverStatusView(){
        //Change constraint
        if self.driverStatusViewTopConstraint.constant < 0{
            self.driverStatusViewTopConstraint.constant = 0
        }else{
            self.driverStatusViewTopConstraint.constant = -100
        }
        
        //Now animate
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func loadMapView(){
        //let newPath = GMSPath(fromEncodedPath: SharingCenter.sharedInstance.myPath!)
        
        
        //Split rider origin and destination
        
        let riderOriginSplit = rider!.origin!.components(separatedBy: ",")
        let riderDestinationSplit = rider!.destination!.components(separatedBy: ",")
        let riderOrigin = CLLocationCoordinate2D(latitude: CLLocationDegrees((riderOriginSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((riderOriginSplit[1] as NSString).doubleValue))
        let riderDestination = CLLocationCoordinate2D(latitude: CLLocationDegrees((riderDestinationSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((riderDestinationSplit[1] as NSString).doubleValue))
        
        let riderStartMarker = GMSMarker(position: riderOrigin)
        riderStartMarker.icon = GMSMarker.markerImage(with: colorHelper.orange)
        let riderEndMarker = GMSMarker(position: riderDestination)
        riderEndMarker.icon = GMSMarker.markerImage(with: colorHelper.orange)
        riderStartMarker.title = "Start"
        riderEndMarker.title = "End"
        
        let bounds = GMSCoordinateBounds(coordinate: riderOrigin, coordinate: riderDestination)
        let update = GMSCameraUpdate.fit(bounds, withPadding: self.mapView.frame.width/6)
        self.mapView.moveCamera(update)
        
        if(type! != "riding"){
            let driverOriginSplit = driver!.origin!.components(separatedBy: ",")
            let driverDestinationSplit = driver!.destination!.components(separatedBy: ",")
            let driverOrigin = CLLocationCoordinate2D(latitude: CLLocationDegrees((driverOriginSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((driverOriginSplit[1] as NSString).doubleValue))
            let driverDestination = CLLocationCoordinate2D(latitude: CLLocationDegrees((driverDestinationSplit[0]as NSString).doubleValue), longitude: CLLocationDegrees((driverDestinationSplit[1] as NSString).doubleValue))
            
            let driverStartMarker = GMSMarker(position: driverOrigin)
            driverStartMarker.icon = GMSMarker.markerImage(with: UIColor.green)
            driverStartMarker.map = mapView
            driverStartMarker.title = "Start"
            
            let driverEndMarker = GMSMarker(position: driverDestination)
            driverEndMarker.title = "End"
            driverEndMarker.map = mapView
            
            riderStartMarker.title = "Rider Start"
            riderEndMarker.title = "Rider End"
            
            let bounds = GMSCoordinateBounds(coordinate: driverOrigin, coordinate: driverDestination)
            let update = GMSCameraUpdate.fit(bounds, withPadding: self.mapView.frame.width/6)
            self.mapView.moveCamera(update)
            
            let mh = MapsHelper()
            mh.start = self.driver?.origin
            mh.end = self.driver?.destination
            mh.rstart = self.rider?.origin
            mh.rend = self.rider?.destination
            
            mh.makeDirectionsRequest({(result) -> Void in
                DispatchQueue.main.async(execute: {
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
                DispatchQueue.main.async(execute: {
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
        let dest = self.currentDestination!.replacingOccurrences(of: " ", with: "+")
        
        //Add waypoints here
        
        //Check if Google Maps is installed
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!){
            
            //Open Google Maps
            UIApplication.shared.openURL(URL(string: "comgooglemaps-x-callback://?saddr=&daddr=" + dest + "&directionsmode=driving&x-success=yokwe://?resume=true&x-source=Yokwe")!)
            
        //Otherwise open Apple Maps
        }else{
            UIApplication.shared.openURL(URL(string: "http://maps.apple.com/?daddr=\(dest)")!)
            
        }
        
    }
    
    @IBAction func pressedPickup(_ sender: AnyObject) {
        
        print("pickup happened")
        
        completedPickUp = true
        status = "leg2"
        
        self.currentDestination = rider?.destination!
        
        //Notify server that rider has been picked up
        YokweHelper.pickUp((self.rider?.userID)!)
        
        //Change driver status view
        driverInstructionLabel.text = "Drop \(rider!.name!) off at"
        driverWaypointLabel.text = "\(rider!.destinationAddress!)"
    }
    
    //Cancels the trip - no charge is made. Exactly like end trip otherwise
    func pressedCancel() {
        
        //Confirm that driver is ready to end the trip
        let alertString = "This will end the trip early, so no charge will be made. Are you sure about this?"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(ACTION) in
            
            //Send message to server to end trip and return to homescreen
            YokweHelper.cancelTrip((self.rider?.userID)!, driverID: (self.driver?.userID)!)
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //Starts the trip, alerts the rider about what is going on and starts sending location data to server
    @IBAction func startTrip(_ sender: AnyObject) {
        
        status = "leg1"
        SharingCenter.sharedInstance.locationManager?.startUpdatingLocation()
        YokweHelper.startTrip((self.rider?.userID)!)
        
        //Handle button animation
        self.startTripButton.isEnabled = false
        self.startTripButton.frame.offsetInPlace(dx: 0, dy: -(startTripButton.frame.height))
        UIView.animate(withDuration: 0.5, animations: {
            self.startTripButton.frame.offsetInPlace(dx: 0, dy: -(self.startTripButton.frame.height))
            self.startTripButton.layer.opacity = 0
            self.view.layoutIfNeeded()
        })
        
        //Slide driver status view
        slideDriverStatusView()
    }
    
    //Completes the trip and charges the rider
    @IBAction func endTrip(){
        
        //Confirm that driver is ready to end the trip
        let alertString = "This will end the trip and you will be paid \(driver!.price!)"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
            
            //Send message to server to end trip and return to homescreen
            YokweHelper.endTrip((self.rider?.userID)!, driverID: (self.driver?.userID)!)
            
            //Stop updating location
            SharingCenter.sharedInstance.locationManager?.stopUpdatingLocation()
            
            //Dismiss the view controller
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Never mind", style: UIAlertActionStyle.default, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func updateDriverStatus(){
        //Update status bar appropriately
        if status == "leg2"{
            containerVC?.cancel.alpha = 0
            containerVC?.cancel.isEnabled = false
            
            statusBar.alpha = 0
            
        }else if status == "leg1"{
            statusBar.textColor = colorHelper.orange
            statusBar.text = "\((driver?.name)!) is en route"
            
        }else{
            statusBar.textColor = UIColor.orange
            statusBar.text = "Waiting for \((driver?.name)!) to start the trip."
        }
    }
    
    func tappedPhoto() {
        //Present profile with phone number
        presentProfile()
        
    }
    
    func presentProfile(){
        var selfProfile = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
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
        navController = UIHelper.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)
    }
    
    func customizeNavController(_ navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        return navController
    }
    
    func customizeVC(_ vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.plain, target: vc, action: "closeView")
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
        print("failed to update location :(")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Get current location
        let driverLocation = SharingCenter.sharedInstance.locationManager?.location!
        
        //Get the CLLocation from coordinates
        let latLongPickUp = self.rider!.origin!.components(separatedBy: ",")
        let latLongDropOff = self.rider!.destination!.components(separatedBy: ",")
        
        let pickup = CLLocation(latitude: CLLocationDegrees(latLongPickUp[0])!, longitude: CLLocationDegrees(latLongPickUp[1])!)
        let dropOff = CLLocation(latitude: CLLocationDegrees(latLongDropOff[0])!, longitude: CLLocationDegrees(latLongDropOff[1])!)
        
        //Get distance
        let distanceInMetersFromPickup = driverLocation!.distance(from: pickup)
        let distanceInMetersFromDropoff = driverLocation!.distance(from: dropOff)
        
        print("distance from pickup in meters: \(distanceInMetersFromPickup)")
        print("distance from dropoff in meters: \(distanceInMetersFromDropoff)")
        
        //Orginally did this to more precisely determine the location of the driver. I expanded the range for pick ups, so it's not really necessary, but will keep it for now
        //Check if they are within 1000 meters of pickup point
        if distanceInMetersFromPickup < 4000 && status == "leg1"{
            
            //Set location services to be very accurate
            SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            //Determine if they are within 200 meters of the drop off point
            if distanceInMetersFromPickup < 4000 && status == "leg1"{
                pressedPickup(self)
                
                //Notify driver that they have arrived
                if notifiedOfPickup == false{
                    let notification = UILocalNotification()
                    notification.alertBody = "Arriving near \(rider!.name!)'s pick up spot"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    UIApplication.shared.presentLocalNotificationNow(notification)
                    
                    notifiedOfPickup = true
                }
                
                //Set location services to be less accurate to conserve battery
                SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
                
            }
            
            /*
            //show pickup button
            self.pickUp.enabled = true
            self.pickUp.hidden = false
            pickUpButtonWidth.constant += self.view.bounds.width
            //Now animate
            UIView.animateWithDuration(0.5){
                self.pickUp.alpha = 0.9
                self.view.layoutIfNeeded()
            }
            */
            
        //Check if they are within about 1 mile of drop off point and rider has been picked up.
        }else if distanceInMetersFromDropoff < 4000 && status == "leg2"{
            
            //Local notification that they can drop off passenger and end trip
            if notifiedOfDropoff == false{
                print("Got into drop off")
                let notification = UILocalNotification()
                notification.alertBody = "You can now end the trip once you drop \(rider!.name!) off"
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(notification)
                
                notifiedOfDropoff = true
                
                //Hide driver status view
                slideDriverStatusView()
            }
            
            //show end trip button
            self.endTripButton.isEnabled = true
            self.endTripButton.isHidden = false
            
            //Now animate
            UIView.animate(withDuration: 0.5, animations: {
                self.endTripButton.alpha = 0.9
                self.view.layoutIfNeeded()
            })
            
        }

    }

}
