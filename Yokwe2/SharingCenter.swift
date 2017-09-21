//
//  SharingCenter.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/15/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class SharingCenter{
    
    var didJustLogIn:Bool = false
    var accessToken:String?
    var shouldReset = false
    var start:String = ""
    var destination:String = ""
    var mode:String = "rider"
    var userID:String?
    var apnsToken:String?
    var myPath:String?
    var startLocation:CLLocationCoordinate2D?
    var endLocation:CLLocationCoordinate2D?
    var locationManager:CLLocationManager?
    var rider:Rider?
    var aboutMe:String?
    var phone:String?
    var tripTime:String?
    var tripDistance:String?
    var email:String?
    var customerToken:String?
    var accountToken:String?
    var password:String?
    var name:String?
    var latestTripID:String?
    
    static let sharedInstance = SharingCenter()
    
}
