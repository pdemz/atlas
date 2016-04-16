//
//  DateTimeViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 9/12/15.
//  Copyright (c) 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import CoreFoundation
import GoogleMaps

class DateTimeViewController: UIViewController, UITextFieldDelegate, NSStreamDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.revealViewController().delegate = self
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        }
        
        self.bottomView.layer.shadowOpacity = 0.1
        self.bottomView.hidden = true
        
        SharingCenter.sharedInstance.locationManager!.delegate = self
        SharingCenter.sharedInstance.locationManager!.startUpdatingLocation()
        if SharingCenter.sharedInstance.locationManager == nil{
            print("location manager is nil")
        }else{
            print("location manager not nil")
        }
        
        originTextField.delegate = self
        destinationTextField.delegate = self

        self.mapView!.myLocationEnabled = true
        self.mapView!.settings.myLocationButton = true
        
        let mapInsets = UIEdgeInsetsMake(self.destinationTextField.frame.maxY + 40, 0, (self.bottomView.frame.height + 8), 0)
        self.mapView.padding = mapInsets
        
        additionalSetup()
        
    }
    
    func additionalSetup(){
        originTextField.attributedPlaceholder = NSAttributedString(string:"Current location",
            attributes:[NSForegroundColorAttributeName: blue])
        
        originTextField.leftView = UIView(frame: CGRectMake(0, 0, self.startLabel.frame.width+8, originTextField.frame.height))
        originTextField.leftViewMode = UITextFieldViewMode.Always
        
        destinationTextField.leftView = UIView(frame: CGRectMake(0, 0, self.startLabel.frame.width+8, originTextField.frame.height))
        destinationTextField.leftViewMode = UITextFieldViewMode.Always
        
        originTextField.layer.cornerRadius = 4
        originTextField.clipsToBounds = true
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Reset text boxes and locations and ensure bottom view is not visible
        
        if SharingCenter.sharedInstance.shouldReset{
            SharingCenter.sharedInstance.locationManager!.startUpdatingLocation()
            self.mapView.clear()
            
            self.originTextField.text = nil
            self.destinationTextField.text = nil
            startLocation = nil
            endLocation = nil
            SharingCenter.sharedInstance.start = ""
            SharingCenter.sharedInstance.destination = ""
            self.bottomView.hidden = true
            SharingCenter.sharedInstance.shouldReset = false
        }

        
        if SharingCenter.sharedInstance.mode == "driver"{
            self.title = "Drive"
        }else{
            self.title = "Ride"
        }
        
        self.navigationController?.navigationBar.tintColor = colorHelper.orange
        //self.navigationController?.navigationBar.barTintColor = colorHelper.beige
        self.navigationController?.navigationBar.translucent = false
        //self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Helvetica", size: 20)!, NSForegroundColorAttributeName: colorHelper.indigo]
        //self.navigationController
        
    }
    
    //Disables mapview while menu is open
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        if position == FrontViewPosition.Left{
            self.mapView.userInteractionEnabled = true
            if SharingCenter.sharedInstance.mode == "driver"{
                self.title = "Drive"
            }else{
                self.title = "Ride"
            }
        }else{
            self.mapView.userInteractionEnabled = false
        }
    }
    
    //MARK: Properties
    var originWasTapped = false
    var startLocation:String?
    var endLocation:String?
    let blue = colorHelper.blue
    let beige = colorHelper.beige


    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var originTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    // MARK: - Navigation
    func openAutocomplete(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        let visibleRegion = self.mapView.projection.visibleRegion()
        autocompleteController.autocompleteBounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Actions
    @IBAction func originTextFieldTap(sender: AnyObject) {
        originWasTapped = true
        openAutocomplete()
    }
    
    @IBAction func destinationTextFieldTap(sender: AnyObject) {
        openAutocomplete()
    }
    

    //Check that user entered an origin and a destination before progressing
    @IBAction func pressedGo(sender: AnyObject) {
        
        if destinationTextField.text != ""{
            SharingCenter.sharedInstance.start = startLocation!
            SharingCenter.sharedInstance.destination = endLocation!
            SharingCenter.sharedInstance.locationManager!.stopUpdatingLocation()
            
            if SharingCenter.sharedInstance.mode == "driver"{
                //Check if their account info is on file
                if SharingCenter.sharedInstance.accountToken == nil{
                    presentDriverForm()
                    
                }else{
                    performSegueWithIdentifier("driverSegue", sender: sender)
                }
                
            }else if SharingCenter.sharedInstance.mode ==  "rider"{
                //Check if payment info is on file
                if SharingCenter.sharedInstance.customerToken == nil{
                    presentCustomerForm()
                    
                }else{
                    performSegueWithIdentifier("riderSegue", sender: sender)
                    
                }
                
            }
        }
        
    }
    
    func presentCustomerForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentForm") as! PaymentFormViewController
        vc = customizeVC(vc) as! PaymentFormViewController
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func presentDriverForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("DriverAccountCreation") as! DriverAccountCreationViewController
        vc = customizeVC(vc) as! DriverAccountCreationViewController
        vc.title = "Create Driver Account"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: {
            self.pressedGo(self)
        })
    }
 
    func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = false
        
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

extension DateTimeViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {
        if originWasTapped{
            self.originTextField.text = place.name
            startLocation = "\(place.coordinate.latitude),\(place.coordinate.longitude)"
            SharingCenter.sharedInstance.startLocation = place.coordinate
            originWasTapped = false
        }else{
            self.destinationTextField.text = place.name
            endLocation = "\(place.coordinate.latitude),\(place.coordinate.longitude)"
            SharingCenter.sharedInstance.endLocation = place.coordinate
            let helper = MapsHelper()
            helper.start = startLocation!
            helper.end = endLocation!
            
            //Get polyline
            helper.makeDirectionsRequest{(result) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    //These are switched because I was lazy
                    self.duration.text = "(\(helper.distance!))"
                    self.distance.text = helper.duration!
                    self.duration.adjustsFontSizeToFitWidth = true
                    self.distance.adjustsFontSizeToFitWidth = true

                    SharingCenter.sharedInstance.tripTime = helper.duration!
                    SharingCenter.sharedInstance.tripDistance = "(\(helper.distance!))"
                    
                    SharingCenter.sharedInstance.myPath = result
                    let newPath = GMSPath(fromEncodedPath: result)
                    let polyLine = GMSPolyline(path: newPath)
                    polyLine.strokeWidth = 5
                    polyLine.strokeColor = colorHelper.blue
                    let bounds = GMSCoordinateBounds(path: newPath!)
                    self.mapView.clear()
                    polyLine.map = self.mapView
                    let update = GMSCameraUpdate.fitBounds(bounds)
                    self.mapView.moveCamera(update)
                })
            }
            self.bottomView.hidden = false

        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        print(error.description)
    }
    
    func wasCancelled(viewController: GMSAutocompleteViewController!) {
        
        if self.originWasTapped{
            self.originTextField.text = nil
            self.startLocation = "\(SharingCenter.sharedInstance.locationManager!.location!.coordinate.latitude),\(SharingCenter.sharedInstance.locationManager!.location!.coordinate.longitude)"
        }else{
            self.destinationTextField.text = nil
            self.endLocation = nil
            self.mapView.clear()
            self.bottomView.hidden = true
        }
        self.originWasTapped = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DateTimeViewController{
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            SharingCenter.sharedInstance.locationManager!.startUpdatingLocation()
        }else{
            SharingCenter.sharedInstance.locationManager!.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update")
        
        SharingCenter.sharedInstance.startLocation = SharingCenter.sharedInstance.locationManager?.location!.coordinate
        
        startLocation = "\(SharingCenter.sharedInstance.locationManager!.location!.coordinate.latitude),\(SharingCenter.sharedInstance.locationManager!.location!.coordinate.longitude)"
        
        if mapView != nil{
            mapView!.camera = GMSCameraPosition(target: (locations.last?.coordinate)!, zoom: 15, bearing: 0, viewingAngle: 0)
            SharingCenter.sharedInstance.locationManager?.stopUpdatingLocation()
        }
    }
    
    
}
