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

class TitularViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var useEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.readPermissions = ["public_profile", "user_friends", "email", "user_photos", "user_education_history"]
        self.emailLoginButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func emailLogin(sender: AnyObject) {
        
        
        if let email = emailTextField.text{
            if email == ""{
                return
            }
            SharingCenter.sharedInstance.email = email
            
        }else{
            return
        }
        
        if let password = passwordTextField.text{
            if password == ""{
                return
            }
            SharingCenter.sharedInstance.password = password
            
        }else{
            return
        }
        
        YokweHelper.authenticateEmail({(result)-> Void in
            if result == true{
                YokweHelper.getUser({(result) -> Void in
                    if let user = result{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.proceedToHomeScreen(user)
                        })
                        
                    }else{
                        print("invalid credentials")
                    }
                })
            }else{
                print("invalid credentials")
            }
        })
    }
    
    @IBAction func tappedEmail(sender: AnyObject) {
        
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5) {
            self.verticalSpacingConstraint.constant -= self.titleLable.frame.maxY + 75
            self.useEmailLabel.alpha = 0
            self.loginButton.alpha = 0
            self.titleLable.alpha = 0
            self.logo.alpha = 0
            self.loginButton.enabled = false
            self.passwordTextField.enabled = true
            self.passwordTextField.alpha = 1
            self.backButton.enabled = true
            self.backButton.alpha = 1
            self.emailLoginButton.alpha = 1
            self.emailLoginButton.enabled = true
            
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tappedBack(sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5) {
            self.verticalSpacingConstraint.constant += self.titleLable.frame.maxY + 75

            self.useEmailLabel.alpha = 1
            self.loginButton.alpha = 1
            self.titleLable.alpha = 1
            self.logo.alpha = 1
            self.loginButton.enabled = true
            self.passwordTextField.enabled = false
            self.passwordTextField.alpha = 0
            self.backButton.enabled = false
            self.backButton.alpha = 0
            self.emailLoginButton.alpha = 0
            self.emailLoginButton.enabled = false
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    //Facebook login
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil{
            print(error.localizedDescription)
        }else{
            print("login complete")
            
            SharingCenter.sharedInstance.userID = FBSDKAccessToken.currentAccessToken().userID
            SharingCenter.sharedInstance.accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            
            //check if the user has logged in before by fetching info
            YokweHelper.getUser({(result) -> Void in
                if let user = result{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.proceedToHomeScreen(user)
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
    
    @IBAction func signUp(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EmailSignup") as! EmailSignupViewController
        showViewController(vc, sender: sender)
    }
    
    func proceedToHomeScreen(user:User){
        SharingCenter.sharedInstance.didJustLogIn = true
        
        YokweHelper.storeUser()
        
        let selfRider = Rider(name: user.name, origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: SharingCenter.sharedInstance.userID, accessToken: SharingCenter.sharedInstance.accessToken)
        
        if FBSDKAccessToken.currentAccessToken() != nil{
        //Get user name photo and education
            FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
                SharingCenter.sharedInstance.rider = result
            })
        }
        
        SharingCenter.sharedInstance.aboutMe = user.aboutMe
        SharingCenter.sharedInstance.phone = user.phone
        SharingCenter.sharedInstance.accountToken = user.accountToken
        SharingCenter.sharedInstance.customerToken = user.customerToken

        let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = protectedPage
        let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        SharingCenter.sharedInstance.locationManager = CLLocationManager()
        SharingCenter.sharedInstance.locationManager!.requestAlwaysAuthorization()
        SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    //-------
    
    //Bad programming here -- these customize the phone view controller
    
    func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = false
        
        return navController
    }
    
}
