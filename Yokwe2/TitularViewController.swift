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

    var shouldDisplayTutorial = true
    
    @IBOutlet weak var useEmailButton: UIButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var verticalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var logo: UIImageView!
    //@IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var useEmailLabel: UILabel!
    
    var logoFrameMaxY:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.logoFrameMaxY = self.logo.frame.maxY
        
        loginButton.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        loginButton.readPermissions = ["public_profile", "user_friends", "user_photos", "user_education_history"]
        self.emailLoginButton.layer.cornerRadius = 5
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //Display tutorial
        if shouldDisplayTutorial{
            
            shouldDisplayTutorial = false
            
            let tutorial = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            
            DispatchQueue.main.async(execute: {
                self.present(tutorial, animated: true, completion: nil)
                
            })
            
        }
        
    }
    @IBAction func tappedEmailButton(_ sender: AnyObject) {
        tappedEmail()
    }
    
    @IBAction func emailLogin(_ sender: AnyObject) {
        
        
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
                        DispatchQueue.main.async(execute: {
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
    
    func tappedEmail() {
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.verticalSpacingConstraint.constant -= 300
            print("VSC contstant after tapping email: \(self.verticalSpacingConstraint.constant)")
            print("logoFrame:\(self.logo.frame.maxY)")
            print("logoframemaxy: \(self.logoFrameMaxY)")
            
            self.emailTextField.isEnabled = true
            self.emailTextField.alpha = 1
            self.useEmailLabel.alpha = 0
            self.useEmailButton.alpha = 0
            self.useEmailButton.isEnabled = false
            self.loginButton.alpha = 0
            //self.titleLable.alpha = 0
            self.logo.alpha = 0
            self.loginButton.isEnabled = false
            self.passwordTextField.isEnabled = true
            self.passwordTextField.alpha = 1
            self.backButton.isEnabled = true
            self.backButton.alpha = 1
            self.emailLoginButton.alpha = 1
            self.emailLoginButton.isEnabled = true
            
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func tappedBack(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        self.view.layoutIfNeeded()
        self.verticalSpacingConstraint.constant += 300
        UIView.animate(withDuration: 0.5, animations: {
            print("VSC contstant after tapping back: \(self.verticalSpacingConstraint.constant)")
            print("logoFrame:\(self.logo.frame.maxY)")

            self.emailTextField.alpha = 0
            self.emailTextField.isEnabled = false
            self.useEmailButton.alpha = 1
            self.useEmailButton.isEnabled = true
            self.loginButton.alpha = 1
            self.logo.alpha = 1
            self.loginButton.isEnabled = true
            self.passwordTextField.isEnabled = false
            self.passwordTextField.alpha = 0
            self.backButton.isEnabled = false
            self.backButton.alpha = 0
            self.emailLoginButton.alpha = 0
            self.emailLoginButton.isEnabled = false
            
            self.view.layoutIfNeeded()
        }) 
        
    }
    
    //Facebook login
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error.localizedDescription)
        }else{
            print("login complete")
            
            SharingCenter.sharedInstance.userID = FBSDKAccessToken.current().userID
            SharingCenter.sharedInstance.accessToken = FBSDKAccessToken.current().tokenString
            
            //check if the user has logged in before by fetching info
            YokweHelper.getUser({(result) -> Void in
                if let user = result{
                    DispatchQueue.main.async(execute: {
                        self.proceedToHomeScreen(user)
                    })
                }else{
                    print("User does not exist")
                    DispatchQueue.main.async(execute: {
                        self.presentPhoneView()
                    })
                }
            })

        }
        
    }
    
    func presentPhoneView(){
        let phone = self.storyboard?.instantiateViewController(withIdentifier: "PhoneNumber") as! PhoneNumberViewController
        phone.title = "Enter Phone Number"
        
        var navController = UINavigationController(rootViewController: phone)
        navController = self.customizeNavController(navController)
        
        self.present(navController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "EmailSignup") as! EmailSignupViewController
        show(vc, sender: sender)
    }
    
    func proceedToHomeScreen(_ user:User){
        SharingCenter.sharedInstance.didJustLogIn = true
        
        YokweHelper.storeUser()
        
        let selfRider = Rider(name: user.name, origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: SharingCenter.sharedInstance.userID, accessToken: SharingCenter.sharedInstance.accessToken)
        
        if FBSDKAccessToken.current() != nil{
        //Get user name photo and education
            FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
                SharingCenter.sharedInstance.rider = result
            })
        }
        
        //store user data locally
        SharingCenter.sharedInstance.aboutMe = user.aboutMe
        SharingCenter.sharedInstance.phone = user.phone
        SharingCenter.sharedInstance.accountToken = user.accountToken
        SharingCenter.sharedInstance.customerToken = user.customerToken

        let protectedPage = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = protectedPage
        
        //register for push notifications
        let notificationTypes : UIUserNotificationType = [.alert, .badge, .sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        UIApplication.shared.registerForRemoteNotifications()
        
        //storing the user here again to save the apns token
        YokweHelper.storeUser()

        //enable location services
        SharingCenter.sharedInstance.locationManager = CLLocationManager()
        SharingCenter.sharedInstance.locationManager!.requestAlwaysAuthorization()
        SharingCenter.sharedInstance.locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    //-------
    
    //Bad programming here -- these customize the phone view controller
    
    func customizeNavController(_ navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.isTranslucent = true
        
        return navController
    }
    
}
