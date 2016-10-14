//
//  AppDelegate.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 9/12/15.
//  Copyright (c) 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import GoogleMaps
import FBSDKCoreKit
import FBSDKLoginKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        /*
        GMSServices.provideAPIKey("AIzaSyCqZ50c_NV-tYwVOMwxaS4XY-vomaxsOEc")
        
        Stripe.setDefaultPublishableKey("pk_live_bd9UGPnXebRwYRUCsz7a3F5e")
        
        FBSDKLoginButton.classForCoder()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
 */
 
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        var initialViewController: UIViewController
        
        if FBSDKAccessToken.currentAccessToken() != nil{
            
            /*
            
            let selfRider = Rider(name: "", origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: FBSDKAccessToken.currentAccessToken().userID, accessToken: FBSDKAccessToken.currentAccessToken().tokenString)
            
            SharingCenter.sharedInstance.userID = FBSDKAccessToken.currentAccessToken().userID
            
            //updates Facebook info on DB
            YokweHelper.storeUser()
            
            FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
                SharingCenter.sharedInstance.rider = result
            })
            
            YokweHelper.getUser({(result) -> Void in
                if let user = result{
                    SharingCenter.sharedInstance.aboutMe = user.aboutMe
                    SharingCenter.sharedInstance.phone = user.phone
                    SharingCenter.sharedInstance.accountToken = user.accountToken
                    SharingCenter.sharedInstance.customerToken = user.customerToken
                    
                    //Check if user has a phone number on file
                    self.phoneHandler()
                }
            })
 */
 
            let protectedPage = mainStoryBoard.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
            initialViewController = protectedPage
            
            /*
            SharingCenter.sharedInstance.locationManager = CLLocationManager()
            SharingCenter.sharedInstance.locationManager?.requestAlwaysAuthorization()
            SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            */
        }else{
            print("tried to open titular")
            let protectedPage = mainStoryBoard.instantiateViewControllerWithIdentifier("TitularViewController")
            initialViewController = protectedPage
            
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool{
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if FBSDKAccessToken.currentAccessToken() != nil || SharingCenter.sharedInstance.email != nil{
            getUpdate()
            
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        if FBSDKAccessToken.currentAccessToken() != nil || SharingCenter.sharedInstance.email != nil{
            getUpdate()
            application.applicationIconBadgeNumber = 0

        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("device token: \(deviceToken)")
        SharingCenter.sharedInstance.apnsToken = "\(deviceToken)"
        YokweHelper.storeUser()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification received")
        if FBSDKAccessToken.currentAccessToken() != nil || SharingCenter.sharedInstance.email != nil{
            getUpdate()
            application.applicationIconBadgeNumber = 0

        }
        
    }
    
    func getUpdate(){
        return
        YokweHelper.getUpdate({(result) -> Void in
            print("shouldve updated")
            
            if result != nil{
                let type = result!.valueForKey("type") as! String
                if(type == "driveOffer"){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentDriveOffer(result!)
                    })
                }else if(type == "rideRequest"){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentRideRequest(result!)
                    })
                }else if(type == "trip"){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentTrip(result!)
                    })
                }else if(type == "review"){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
                        
                        self.presentReview(result!)
                    })
                }
            }else{
                //Dismiss trip window if it was cancelled
                if  UIApplication.sharedApplication().keyWindow!.rootViewController!.presentedViewController?.childViewControllers.first is TripViewController{
                    print("shouldve dismissed")
                    self.window!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                    
                }
            }
            
        })
    }
    
    func presentReview(json:NSDictionary){
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let review = mainStoryBoard.instantiateViewControllerWithIdentifier("review") as! ReviewViewController
        let navController:UINavigationController = UINavigationController(rootViewController: review)
    
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = true
        
        //Get user photo and name with access token
        if json.valueForKey("accessToken") != nil{
            let reviewee = Rider(userID: json.valueForKey("revieweeID") as! String, accessToken: json.valueForKey("accessToken") as! String)
            
            FacebookHelper.riderGraphRequest(reviewee, completion: { (result)->Void in
                dispatch_async(dispatch_get_main_queue(), {
                    review.photoImage = result.photo
                    review.revieweeID = result.userID
                    review.type = json.valueForKey("review_type") as? String
                    review.title = "Review for \(result.name!)"
                    self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
                })
            })
        }
        
        //In the future - get this directly from json for users without facebook
    }
    
    func phoneHandler(){
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        print("phone:")
        print(SharingCenter.sharedInstance.phone)
        
        if SharingCenter.sharedInstance.phone == nil || SharingCenter.sharedInstance.phone! == ""{
            let vc = mainStoryBoard.instantiateViewControllerWithIdentifier("PhoneNumber") as! PhoneNumberViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            vc.title = "Enter Phone Number"
            
            let navController = UINavigationController(rootViewController: vc)
            navController.navigationBar.tintColor = colorHelper.orange
            navController.navigationBar.translucent = true
            
            self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
        }
        
    }
    
    func presentTrip(json:NSDictionary){
        
        //Set up trip view
        let dj = json.objectForKey("driver")
        
        let mf = json.valueForKey("mutualFriends") as? String
        let driver = Driver(name: nil, photo: nil, mutualFriends: mf, fareEstimate: nil, eta: nil, userID: dj!.valueForKey("id") as? String, accessToken: dj!.valueForKey("accessToken") as? String, addedTime: nil)
        driver.name = dj!.valueForKey("name") as? String
        
        driver.origin = dj!.valueForKey("origin") as? String
        driver.destination = dj!.valueForKey("destination") as? String
        
        //Get price and format it
        let priceNumber = ((json.valueForKey("price") as! Double)/100)
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        driver.price = formatter.stringFromNumber(priceNumber)
        
        driver.aboutMe = dj!.valueForKey("aboutMe") as? String
        driver.phone = dj!.valueForKey("phone") as? String
        
        //Da fuq??
        driver.addedTime = (json.valueForKey("addedTime") as! Double)
        
        let rj = json.objectForKey("rider")
        let rider = Rider(name: nil, origin: rj?.valueForKey("origin") as? String, destination: rj?.valueForKey("destination") as? String, photo: nil, mutualFriends: mf, fareEstimate: nil, addedTime: nil, userID: rj?.valueForKey("id") as? String, accessToken: rj?.valueForKey("accessToken") as? String)
        rider.aboutMe = rj!.valueForKey("aboutMe") as? String
        rider.phone = rj!.valueForKey("phone") as? String
        rider.name = rj?.valueForKey("name") as? String
        
        rider.originAddress = rj!.valueForKey("originAddress") as? String
        rider.destinationAddress = rj!.valueForKey("destinationAddress") as? String
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let driveOffer = mainStoryBoard.instantiateViewControllerWithIdentifier("Trip") as! TripViewController
        
        driveOffer.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        driveOffer.driver = driver
        driveOffer.rider = rider
        driveOffer.status = json.valueForKey("status") as! String
        
        if rider.userID == SharingCenter.sharedInstance.userID{
            driveOffer.type = "riding"
        }else{
            driveOffer.type = "driving"

        }
        
        let navController:UINavigationController = UINavigationController(rootViewController: driveOffer)
        
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = true
        
        print("xxx~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~xxx")
        print(UIApplication.sharedApplication().keyWindow?.rootViewController!.presentedViewController?.childViewControllers.first?.title)
        
        if rider.userID == SharingCenter.sharedInstance.userID{
            driveOffer.totalTripTime = (rj?.valueForKey("duration") as! Double)
            
            //Update view controller if this is already on display
            if let tripVC = UIApplication.sharedApplication().keyWindow!.rootViewController!.presentedViewController?.childViewControllers.first as? TripViewController{
                tripVC.status = json.valueForKey("status") as! String
                print("status should have been updated!!")
                tripVC.updateDriverStatus()
                
            }
            
            FacebookHelper.driverGraphRequest(driver, completion: { (result)->Void in
                dispatch_async(dispatch_get_main_queue(), {
                    driveOffer.driver = result
                    self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
                })
            })
            
        }else{
            driveOffer.totalTripTime = json.valueForKey("duration") as? Double
            
            FacebookHelper.riderGraphRequest(rider, completion: { (result)->Void in
                dispatch_async(dispatch_get_main_queue(), {
                    driveOffer.rider = result
                    self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
                })
            })
            
        }
        
    }
    
    func presentDriveOffer(jsonResults:NSDictionary){
        let mf = jsonResults.valueForKey("mutualFriends") as? String

        //Get the driver info
        let driverID = jsonResults.valueForKey("driverID") as! String
        let accessToken = jsonResults.valueForKey("driverAccessToken") as? String
        let driver = Driver(name: nil, photo: nil, mutualFriends: mf, fareEstimate: nil, eta: nil, userID: driverID, accessToken: accessToken, addedTime: nil)
        
        //Get price and format it
        let priceNumber = ((jsonResults.valueForKey("price") as! Double)/100)
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        driver.price = formatter.stringFromNumber(priceNumber)
        
        let origin = jsonResults.valueForKey("origin") as! String
        let destination = jsonResults.valueForKey("destination") as! String
        let duration = jsonResults.valueForKey("duration") as! Double
        
        let rider = Rider(name: nil, origin: origin, destination: destination, photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: nil, userID: nil, accessToken: nil)
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let driveOffer = mainStoryBoard.instantiateViewControllerWithIdentifier("OfferResponse") as! OfferResponseViewController
        
        driveOffer.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        driveOffer.totalTripTime = duration
        driveOffer.driver = driver
        driveOffer.rider = rider
        driveOffer.type = "ride"
        
        let navController:UINavigationController = UINavigationController(rootViewController: driveOffer)
        
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = true
        
        FacebookHelper.driverGraphRequest(driver, completion: { (result)->Void in
            dispatch_async(dispatch_get_main_queue(), {
                driveOffer.driver = result
                self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
            })
        })
    }
    
    func presentRideRequest(jsonResults:NSDictionary){
        let mf = jsonResults.valueForKey("mutualFriends") as? String

        let id = jsonResults.valueForKey("riderID") as! String
        let accessToken = jsonResults.valueForKey("accessToken") as? String
        let driver = Driver(name: nil, photo: nil, mutualFriends: nil, fareEstimate: nil, eta: nil, userID: nil, accessToken: nil, addedTime: nil)
        driver.destination = jsonResults.valueForKey("driverDestination") as? String
        driver.origin = jsonResults.valueForKey("driverOrigin") as? String
        driver.addedTime = jsonResults.valueForKey("addedTime") as? Double
        
        //Get price and format it
        let priceNumber = ((jsonResults.valueForKey("price") as! Double)/100)
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        driver.price = formatter.stringFromNumber(priceNumber)
        
        let riderOrigin = jsonResults.valueForKey("riderOrigin") as! String
        let riderDestination = jsonResults.valueForKey("riderDestination") as! String
        let duration = jsonResults.valueForKey("driverDuration") as! String
        
        let rider = Rider(name: nil, origin: riderOrigin, destination: riderDestination, photo: nil, mutualFriends: mf, fareEstimate: nil, addedTime: nil, userID: id, accessToken: accessToken)
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let driveOffer = mainStoryBoard.instantiateViewControllerWithIdentifier("OfferResponse") as! OfferResponseViewController
        
        driveOffer.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        driveOffer.totalTripTime = Double(duration)
        driveOffer.driver = driver
        driveOffer.rider = rider
        driveOffer.type = "drive"
        
        let navController:UINavigationController = UINavigationController(rootViewController: driveOffer)
        
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = true
        
        FacebookHelper.riderGraphRequest(rider, completion: { (result)->Void in
            dispatch_async(dispatch_get_main_queue(), {
                driveOffer.rider = result
                self.window?.rootViewController?.presentViewController(navController, animated: true, completion: nil)
            })
        })
    }


}

