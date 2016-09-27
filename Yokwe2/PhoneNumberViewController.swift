//
//  PhoneNumberViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/1/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import MapKit

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        phone.delegate = self
        phone.keyboardType = .PhonePad

        continueButton.alpha = 0.5
        continueButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Enter Phone Number"
        
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: self, action: "closeView")
        self.navigationItem.leftBarButtonItem = dismissButton
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = ""
    }
    
    @IBAction func continuePress(sender: AnyObject) {
        proceedToHomeScreen()
    }
    
    //Formats the phone number as the user enters it
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == phone{
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.characterAtIndex(0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            if length == 10{
                continueButton.alpha = 1
                continueButton.enabled = true
            }else{
                continueButton.alpha = 0.5
                continueButton.enabled = false
            }
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
            
        }else{
            return true
        }
    }
    
    func proceedToHomeScreen(){
       // let selfRider = Rider(name: "", origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: FBSDKAccessToken.currentAccessToken().userID, accessToken: FBSDKAccessToken.currentAccessToken().tokenString)
        
        YokweHelper.storeUser()
        
        //Notice this is called after store user - this is because we only want to store this number if the user confirms it.
        SharingCenter.sharedInstance.phone = phone.text
        
        YokweHelper.requestVerificationCode()
        
        /*FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
            SharingCenter.sharedInstance.rider = result
        })
 */       
 
        let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        SharingCenter.sharedInstance.locationManager = CLLocationManager()
        SharingCenter.sharedInstance.locationManager!.requestWhenInUseAuthorization()
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("PhoneConfirmation") as! PhoneConfirmationViewController
        self.showViewController(vc, sender: self)
        
        /*let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        
        presentViewController(protectedPage, animated: false, completion: nil)
 */
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func closeView(){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
}
