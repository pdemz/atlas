//
//  TripViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/26/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import GoogleMaps

class TripViewController: UIViewController {
    
    var driver:Driver?
    var rider:Rider?
    var totalTripTime:Double?
    var type:String? //ride or drive
    var currentDestination:String?
    
    @IBOutlet weak var pickUp: UIButton!
    @IBOutlet weak var endTrip: UIButton!
    @IBOutlet weak var navigate: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var tripTimesView: UIView!
    @IBOutlet weak var totalTripTimeLabel: UILabel!
    @IBOutlet weak var addedTimeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        tripTimesView.layer.borderWidth = 0.3
        tripTimesView.layer.borderColor = UIColor.lightGrayColor().CGColor
        totalTripTimeLabel.text = "Trip duration: \(Int(totalTripTime!/60)) hr \(Int(totalTripTime!)%60) min"
        
        endTrip.layer.backgroundColor = colorHelper.pink.CGColor
        navigate.layer.backgroundColor = colorHelper.orange.CGColor
        
        
        if type == "riding"{
            self.title = "Riding"
            name.text = driver!.name
            photo.image = driver!.photo
            
            self.pickUp.enabled = false
            self.pickUp.hidden = true
            
            currentDestination = rider?.destination
            addedTimeLabel.hidden = true
        }else{
            self.title = "Driving"
            name.text = rider!.name
            photo.image = rider!.photo
            
            pickUp.setTitle("Tap here once you've picked \(rider!.name!) up", forState: .Normal)
            pickUp.titleLabel?.adjustsFontSizeToFitWidth = true
            currentDestination = rider?.origin
            let hours = Int((driver?.addedTime!)!/60)
            let mins = Int((driver?.addedTime!)!)%60
            addedTimeLabel.text = "Added time: \(hours) hr \(mins) min"
        }
        
        loadMapView()
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
        let update = GMSCameraUpdate.fitBounds(bounds, withPadding: self.mapView.frame.width/5)
        self.mapView.moveCamera(update)
        
        if(type != "riding"){
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
                })
            })
        }

        
        riderStartMarker.map = mapView
        riderEndMarker.map = mapView
        
        //Generate path with maps helper
        
    }

    @IBAction func pressedNavigate(sender: AnyObject) {
        //Open google maps, and route to currentDestination
        let dest = self.currentDestination!.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        //Check if Google Maps is installed
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!){
            
            //Open Google Maps
            UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps-x-callback://?saddr=&daddr=" + dest + "&directionsmode=driving&x-success=yokwe://?resume=true&x-source=Yokwe")!)
        }
        
    }
    
    @IBAction func pressedPickup(sender: AnyObject) {
        
        self.currentDestination = rider?.destination!
        self.pickUp.enabled = false
        
        UIView.animateWithDuration(0.1, animations: {
            self.pickUp.layer.opacity = 0
        })
        
    }
    
    @IBAction func endTrip(sender: AnyObject) {
        YokweHelper.endTrip((rider?.userID)!, driverID: (driver?.userID)!)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func tappedPhoto(sender: AnyObject) {
        //Present profile with phone number
        presentProfile()
        
    }
    
    func presentProfile(){
        var selfProfile = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController
        selfProfile = customizeVC(selfProfile) as! UserProfileViewController
        
        //Get driver info
        if self.type == "riding"{
            selfProfile.title = self.driver?.name
            selfProfile.photoImage = self.driver?.photo
            selfProfile.phoneText = self.driver?.phone
            selfProfile.aboutMeText = self.driver?.aboutMe
            selfProfile.locationText = self.driver?.mutualFriends
            
            print("driverPhone = \(self.driver?.phone)")
            
            //else get rider info
        }else{
            selfProfile.title = self.rider?.name
            selfProfile.photoImage = self.rider?.photo
            selfProfile.phoneText = self.rider?.phone
            selfProfile.aboutMeText = self.rider?.aboutMe
            selfProfile.locationText = self.rider?.mutualFriends

        }
        
        
        var navController = UINavigationController(rootViewController: selfProfile)
        navController = customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.redOrange
        navController.navigationBar.barTintColor = colorHelper.beige
        navController.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Arial", size: 24)!, NSForegroundColorAttributeName: colorHelper.indigo]
        
        return navController
    }
    
    func customizeVC(vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: vc, action: "closeView")
        vc.navigationItem.leftBarButtonItem = dismissButton
        
        return vc
    }


}
