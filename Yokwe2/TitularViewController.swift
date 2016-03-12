//
//  TitularViewController.swift
//  
//
//  Created by Pierce Demarreau on 11/18/15.
//
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import MapKit

class TitularViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "user_friends", "email", "user_photos"]
        
    }
    
    // MARK: Facebook login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil{
            print(error.localizedDescription)
        }else{
            print("login complete")
            
            SharingCenter.sharedInstance.userID = FBSDKAccessToken.currentAccessToken().userID
            
            //check if the user has logged in before
            YokweHelper.doesUserExist({(result) -> Void in
                if result == true{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.proceedToHomeScreen()
                    })
                }else{
                    print("User does not exist")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.presentPhoneView()
                    })
                }
            })

        }
        
    }
    
    func presentPhoneView(){
        let phone = self.storyboard?.instantiateViewControllerWithIdentifier("PhoneNumber") as! PhoneNumberViewController
        phone.title = "Enter Phone Number"
        
        var navController = UINavigationController(rootViewController: phone)
        navController = self.customizeNavController(navController)
        
        self.presentViewController(navController, animated: true, completion: nil)
        
        
    }
    
    func proceedToHomeScreen(){
        YokweHelper.storeUser()
        
        let selfRider = Rider(name: "", origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: FBSDKAccessToken.currentAccessToken().userID, accessToken: FBSDKAccessToken.currentAccessToken().tokenString)
        
        //Get user name and photo
        FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
            SharingCenter.sharedInstance.rider = result
        })
        
        YokweHelper.getProfile({(result) -> Void in
            let profileInfo = result?.componentsSeparatedByString(";")
            if let aboutMe = profileInfo?[0]{
                SharingCenter.sharedInstance.aboutMe = aboutMe
            }
            SharingCenter.sharedInstance.phone = profileInfo![1]
        })
        
        let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = protectedPage
        let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        SharingCenter.sharedInstance.locationManager = CLLocationManager()
        SharingCenter.sharedInstance.locationManager!.requestWhenInUseAuthorization()

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    //-------
    
    //Bad programming here -- these customize the phone view controller
    
    func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.redOrange
        navController.navigationBar.barTintColor = colorHelper.beige
        navController.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Arial", size: 24)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        return navController
    }
    
}
