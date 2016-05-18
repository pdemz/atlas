//
//  EmailSignupViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 5/1/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import MapKit

class EmailSignupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    
    var allCompleted = false
    var phoneIsValid = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for case let textField as UITextField in self.view.subviews{
            textField.delegate = self
        }
        
        phone.keyboardType = .PhonePad
    }
    
    @IBAction func createAccount(sender: AnyObject) {
        proceedToHomeScreen()
    }
    
    func checkFields() {
        allCompleted = true
        for case let textField as UITextField in self.view.subviews{
            
            if textField.text == nil || textField.text! == ""{
                allCompleted = false
            }
        }
        
        if phoneIsValid && allCompleted && password.text! == confirmPassword.text!{
            continueButton.alpha = 1
            continueButton.enabled = true
        }else{
            continueButton.alpha = 0.5
            continueButton.enabled = false
        }
    }
    
    func proceedToHomeScreen(){
        
        let selfRider = Rider(name: "", origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: nil, accessToken: nil)
        
        SharingCenter.sharedInstance.phone = phone.text
        SharingCenter.sharedInstance.email = email.text
        SharingCenter.sharedInstance.name = name.text
        SharingCenter.sharedInstance.password = password.text
        
        //Store credentials locally here
        let defaults = NSUserDefaults.standardUserDefaults()
        
        /*
        defaults.setObject(email, forKey: "email")
        defaults.setObject(password.text!, forKey: "password")
        */
        //
        
        //YokweHelper.storeUser()
        
        FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
            SharingCenter.sharedInstance.rider = result
        })
        
        let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        SharingCenter.sharedInstance.locationManager = CLLocationManager()
        SharingCenter.sharedInstance.locationManager!.requestWhenInUseAuthorization()
        
        let protectedPage = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
        
        presentViewController(protectedPage, animated: false, completion: nil)
        
    }
    
    //Formats the phone number as the user enters it
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
     
        checkFields()
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
                phoneIsValid = true
                
            }else{
                phoneIsValid = false
        
            }
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            checkFields()
            return false
            
        }else{
            
            checkFields()
            return true
        }
    }

}
