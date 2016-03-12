//
//  MapTestViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/26/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import GoogleMaps

class MapTestViewController:UIViewController, CLLocationManagerDelegate {
    
    //Get lat and long for user origin and destination and return them to be used here.
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera = GMSCameraPosition.cameraWithLatitude(0, longitude: 0, zoom: 0)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.settings.compassButton = true
        
        let mapInsets = UIEdgeInsetsMake(0, 0, 45.0, 0)
        mapView.padding = mapInsets
        
        self.view = mapView
        
        //mapView.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateLocation(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        updateLocation(false)
        updateLocation(true)
    }
    
    func updateLocation(running: Bool){
        let mapView = self.view as! GMSMapView
        let status = CLLocationManager.authorizationStatus()
        
        if running && status == CLAuthorizationStatus.AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }else{
            locationManager.stopUpdatingLocation()
            mapView.myLocationEnabled = false
            mapView.settings.myLocationButton = false
        }
    }
    
    
    



}

