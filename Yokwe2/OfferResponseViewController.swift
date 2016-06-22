//
//  DriveOfferResponseViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/22/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import GoogleMaps
import Foundation

class OfferResponseViewController: UIViewController {
    
    var driver:Driver?
    var rider:Rider?
    var totalTripTime:Double?
    var type:String? //ride or drive
    
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var tripTimesView: UIView!
    @IBOutlet weak var totalTripTimeLabel: UILabel!
    @IBOutlet weak var addedTimeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up photo
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        //Set up buttons
        acceptButton.layer.cornerRadius = 4
        rejectButton.layer.cornerRadius = 4
        
        totalTripTimeLabel.text = "\(Int(totalTripTime!/3600)) hr \(Int(totalTripTime!/60)%60) min total"
                
        price.text = "$\((driver?.price!)!)"
        
        price.adjustsFontSizeToFitWidth = true
        totalTripTimeLabel.adjustsFontSizeToFitWidth = true
        addedTimeLabel.adjustsFontSizeToFitWidth = true
        
        if(type! == "ride"){
            self.title = "Ride offer"
            name.text = driver!.name
            photo.image = driver!.photo
            addedTimeLabel.hidden = true
        }else{
            self.title = "Ride request"
            name.text = rider!.name
            photo.image = rider!.photo
            //let hours = Int((driver?.addedTime!)!/60)
            let mins = Int((driver?.addedTime!)!)%60
            addedTimeLabel.text = "+\(mins) min"
        }
        
        loadMapView()
    }

    func loadMapView(){
        //let newPath = GMSPath(fromEncodedPath: SharingCenter.sharedInstance.myPath!)
        
        let mapInsets = UIEdgeInsetsMake(0, 0, (self.acceptButton.frame.height + 16), 0)
        self.mapView.padding = mapInsets
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
        
        if(type == "drive"){
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
            let update = GMSCameraUpdate.fitBounds(bounds, withPadding: self.mapView.frame.width/5)
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
            
            //Show polyline
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

    @IBAction func pressedReject(sender: AnyObject) {
        if type == "ride"{
            YokweHelper.driveReject((driver?.userID)!)
        }else{
            YokweHelper.rideReject((rider?.userID)!)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pressedAccept(sender: AnyObject) {
        if type == "ride"{
            YokweHelper.acceptRequest((driver?.userID)!, requestType: "drive")
        }else{
            YokweHelper.acceptRequest((rider?.userID)!, requestType: "ride")
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.getUpdate()
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func tappedPhoto(sender: AnyObject) {
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
            selfProfile.educationText = self.driver?.education
            
            print("driverPhone = \(self.driver?.phone)")
            
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


}
