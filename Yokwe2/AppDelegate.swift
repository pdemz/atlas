//
//  AppDelegate.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 9/12/15.
//  Copyright (c) 2015 Pierce Demarreau. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FBSDKCoreKit
import FBSDKLoginKit
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("###")
        GMSPlacesClient.provideAPIKey("###")
        
        //Stripe.setDefaultPublishableKey("###")
        STPPaymentConfiguration.shared().publishableKey = "###"
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
 
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        var initialViewController: UIViewController
        
        if FBSDKAccessToken.current() != nil{
            
            
            let selfRider = Rider(name: "", origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: FBSDKAccessToken.current().userID, accessToken: FBSDKAccessToken.current().tokenString)
            
            SharingCenter.sharedInstance.userID = FBSDKAccessToken.current().userID
            
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
 
            let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
            initialViewController = protectedPage
            
            
            SharingCenter.sharedInstance.locationManager = CLLocationManager()
            SharingCenter.sharedInstance.locationManager?.requestAlwaysAuthorization()
            SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            
            
        }else{
            print("tried to open titular")
            let protectedPage = mainStoryBoard.instantiateViewController(withIdentifier: "TitularViewController")
            initialViewController = protectedPage
            
        }
        
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        return true
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool{
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if FBSDKAccessToken.current() != nil || SharingCenter.sharedInstance.email != nil{
            getUpdate()
            
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        if FBSDKAccessToken.current() != nil || SharingCenter.sharedInstance.email != nil{
            getUpdate()
            application.applicationIconBadgeNumber = 0

        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        SharingCenter.sharedInstance.apnsToken = "\(token)"
        YokweHelper.storeUser()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Notification received")
        if FBSDKAccessToken.current() != nil || SharingCenter.sharedInstance.email != nil{
            getUpdate()
            application.applicationIconBadgeNumber = 0

        }
        
    }
    
    func getUpdate(){
        return
        YokweHelper.getUpdate({(result) -> Void in
            print("shouldve updated")
            
            if result != nil{
                let type = result!.value(forKey: "type") as! String
                if(type == "driveOffer"){
                    DispatchQueue.main.async(execute: {
                        self.presentDriveOffer(result!)
                    })
                }else if(type == "rideRequest"){
                    DispatchQueue.main.async(execute: {
                        self.presentRideRequest(result!)
                    })
                }else if(type == "trip"){
                    DispatchQueue.main.async(execute: {
                        self.presentTrip(result!)
                    })
                }else if(type == "review"){
                    DispatchQueue.main.async(execute: {
                        self.window!.rootViewController?.dismiss(animated: false, completion: nil)
                        
                        self.presentReview(result!)
                    })
                }
            }else{
                //Dismiss trip window if it was cancelled
                if  UIApplication.shared.keyWindow!.rootViewController!.presentedViewController?.childViewControllers.first is TripViewController{
                    print("shouldve dismissed")
                    self.window!.rootViewController?.dismiss(animated: true, completion: nil)
                    
                }
            }
            
        })
    }
    
    func presentReview(_ json:NSDictionary){
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let review = mainStoryBoard.instantiateViewController(withIdentifier: "review") as! ReviewViewController
        var navController:UINavigationController = UINavigationController(rootViewController: review)
    
        navController = UIHelper.customizeNavController(navController)
        
        //Get user photo and name with access token
        if json.value(forKey: "accessToken") != nil{
            let reviewee = Rider(userID: json.value(forKey: "revieweeID") as! String, accessToken: json.value(forKey: "accessToken") as! String)
            
            FacebookHelper.riderGraphRequest(reviewee, completion: { (result)->Void in
                DispatchQueue.main.async(execute: {
                    review.photoImage = result.photo
                    review.revieweeID = result.userID
                    review.type = json.value(forKey: "review_type") as? String
                    review.title = "Review for \(result.name!)"
                    self.window?.rootViewController?.present(navController, animated: true, completion: nil)
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
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "PhoneNumber") as! PhoneNumberViewController
            vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            vc.title = "Enter Phone Number"
            
            var navController = UINavigationController(rootViewController: vc)
            navController = UIHelper.customizeNavController(navController)
            
            self.window?.rootViewController?.present(navController, animated: true, completion: nil)
        }
        
    }
    
    func presentTrip(_ json:NSDictionary){
        
        //Set up trip view
        let dj = json.object(forKey: "driver")
        
        let mf = json.value(forKey: "mutualFriends") as? String
        let driver = Driver(name: nil, photo: nil, mutualFriends: mf, fareEstimate: nil, eta: nil, userID: (dj! as AnyObject).value(forKey: "id") as? String, accessToken: (dj! as AnyObject).value(forKey: "accessToken") as? String, addedTime: nil)
        driver.name = (dj! as AnyObject).value(forKey: "name") as? String
        
        driver.origin = (dj! as AnyObject).value(forKey: "origin") as? String
        driver.destination = (dj! as AnyObject).value(forKey: "destination") as? String
        
        //Get price and format it
        let priceNumber = ((json.value(forKey: "price") as! Double)/100) as NSNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        let finalPrice = formatter.string(from: priceNumber)// "123.44$"
        
        driver.price = finalPrice
        
        driver.aboutMe = (dj! as AnyObject).value(forKey: "aboutMe") as? String
        driver.phone = (dj! as AnyObject).value(forKey: "phone") as? String
        
        //Da fuq??
        driver.addedTime = (json.value(forKey: "addedTime") as! Double)
        
        let rj = json.object(forKey: "rider")
        let rider = Rider(name: nil, origin: (rj as AnyObject).value(forKey: "origin") as? String, destination: (rj as AnyObject).value(forKey: "destination") as? String, photo: nil, mutualFriends: mf, fareEstimate: nil, addedTime: nil, userID: (rj as AnyObject).value(forKey: "id") as? String, accessToken: (rj as AnyObject).value(forKey: "accessToken") as? String)
        rider.aboutMe = (rj! as AnyObject).value(forKey: "aboutMe") as? String
        rider.phone = (rj! as AnyObject).value(forKey: "phone") as? String
        rider.name = (rj as AnyObject).value(forKey: "name") as? String
        
        rider.originAddress = (rj! as AnyObject).value(forKey: "originAddress") as? String
        rider.destinationAddress = (rj! as AnyObject).value(forKey: "destinationAddress") as? String
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let driveOffer = mainStoryBoard.instantiateViewController(withIdentifier: "Trip") as! TripViewController
        
        driveOffer.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        driveOffer.driver = driver
        driveOffer.rider = rider
        driveOffer.status = json.value(forKey: "status") as! String
        
        if rider.userID == SharingCenter.sharedInstance.userID{
            driveOffer.type = "riding"
        }else{
            driveOffer.type = "driving"

        }
        
        var navController:UINavigationController = UINavigationController(rootViewController: driveOffer)
        
        navController = UIHelper.customizeNavController(navController)
        
        print("xxx~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~xxx")
        print(UIApplication.shared.keyWindow?.rootViewController!.presentedViewController?.childViewControllers.first?.title)
        
        if rider.userID == SharingCenter.sharedInstance.userID{
            driveOffer.totalTripTime = ((rj as AnyObject).value(forKey: "duration") as! Double)
            
            //Update view controller if this is already on display
            if let tripVC = UIApplication.shared.keyWindow!.rootViewController!.presentedViewController?.childViewControllers.first as? TripViewController{
                tripVC.status = json.value(forKey: "status") as! String
                print("status should have been updated!!")
                tripVC.updateDriverStatus()
                
            }
            
            FacebookHelper.driverGraphRequest(driver, completion: { (result)->Void in
                DispatchQueue.main.async(execute: {
                    driveOffer.driver = result
                    self.window?.rootViewController?.present(navController, animated: true, completion: nil)
                })
            })
            
        }else{
            driveOffer.totalTripTime = json.value(forKey: "duration") as? Double
            
            FacebookHelper.riderGraphRequest(rider, completion: { (result)->Void in
                DispatchQueue.main.async(execute: {
                    driveOffer.rider = result
                    self.window?.rootViewController?.present(navController, animated: true, completion: nil)
                })
            })
            
        }
        
    }
    
    func presentDriveOffer(_ jsonResults:NSDictionary){
        let mf = jsonResults.value(forKey: "mutualFriends") as? String

        //Get the driver info
        let driverID = jsonResults.value(forKey: "driverID") as! String
        let accessToken = jsonResults.value(forKey: "driverAccessToken") as? String
        let driver = Driver(name: nil, photo: nil, mutualFriends: mf, fareEstimate: nil, eta: nil, userID: driverID, accessToken: accessToken, addedTime: nil)
        
        //Get price and format it
        let priceNumber = ((jsonResults.value(forKey: "price") as! Double)/100) as NSNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        let finalPrice = formatter.string(from: priceNumber)// "123.44$"
        
        driver.price = finalPrice
        
        let origin = jsonResults.value(forKey: "origin") as! String
        let destination = jsonResults.value(forKey: "destination") as! String
        let duration = jsonResults.value(forKey: "duration") as! Double
        
        let rider = Rider(name: nil, origin: origin, destination: destination, photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: nil, userID: nil, accessToken: nil)
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let driveOffer = mainStoryBoard.instantiateViewController(withIdentifier: "OfferResponse") as! OfferResponseViewController
        
        driveOffer.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        driveOffer.totalTripTime = duration
        driveOffer.driver = driver
        driveOffer.rider = rider
        driveOffer.type = "ride"
        
        var navController:UINavigationController = UINavigationController(rootViewController: driveOffer)
        
        navController = UIHelper.customizeNavController(navController)
        
        FacebookHelper.driverGraphRequest(driver, completion: { (result)->Void in
            DispatchQueue.main.async(execute: {
                driveOffer.driver = result
                self.window?.rootViewController?.present(navController, animated: true, completion: nil)
            })
        })
    }
    
    func presentRideRequest(_ jsonResults:NSDictionary){
        let mf = jsonResults.value(forKey: "mutualFriends") as? String

        let id = jsonResults.value(forKey: "riderID") as! String
        let accessToken = jsonResults.value(forKey: "accessToken") as? String
        let driver = Driver(name: nil, photo: nil, mutualFriends: nil, fareEstimate: nil, eta: nil, userID: nil, accessToken: nil, addedTime: nil)
        driver.destination = jsonResults.value(forKey: "driverDestination") as? String
        driver.origin = jsonResults.value(forKey: "driverOrigin") as? String
        driver.addedTime = jsonResults.value(forKey: "addedTime") as? Double
        
        //Get price and format it
        let priceNumber = ((jsonResults.value(forKey: "price") as! Double)/100) as NSNumber
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        let finalPrice = formatter.string(from: priceNumber)// "123.44$"
        
        driver.price = finalPrice
        
        let riderOrigin = jsonResults.value(forKey: "riderOrigin") as! String
        let riderDestination = jsonResults.value(forKey: "riderDestination") as! String
        let duration = jsonResults.value(forKey: "driverDuration") as! String
        
        let rider = Rider(name: nil, origin: riderOrigin, destination: riderDestination, photo: nil, mutualFriends: mf, fareEstimate: nil, addedTime: nil, userID: id, accessToken: accessToken)
        
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let driveOffer = mainStoryBoard.instantiateViewController(withIdentifier: "OfferResponse") as! OfferResponseViewController
        
        driveOffer.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        driveOffer.totalTripTime = Double(duration)
        driveOffer.driver = driver
        driveOffer.rider = rider
        driveOffer.type = "drive"
        
        var navController:UINavigationController = UINavigationController(rootViewController: driveOffer)
        
        navController = UIHelper.customizeNavController(navController)
        
        FacebookHelper.riderGraphRequest(rider, completion: { (result)->Void in
            DispatchQueue.main.async(execute: {
                driveOffer.rider = result
                self.window?.rootViewController?.present(navController, animated: true, completion: nil)
            })
        })
    }


}

