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
        
        phone.keyboardType = .phonePad
    }
    
    @IBAction func createAccount(_ sender: AnyObject) {
        proceedToHomeScreen()
    }
    
    func checkFields() {
        allCompleted = true
        for case let textField as UITextField in self.view.subviews{
            
            if textField.text == nil || textField.text! == ""{
                allCompleted = false
            }
        }
        
        if allCompleted && password.text! == confirmPassword.text!{
            continueButton.alpha = 1
            continueButton.isEnabled = true
        }else{
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    func proceedToHomeScreen(){
        
        let selfRider = Rider(name: "", origin: "", destination: "", photo: nil, mutualFriends: nil, fareEstimate: nil, addedTime: "", userID: nil, accessToken: nil)
        
        SharingCenter.sharedInstance.email = email.text
        SharingCenter.sharedInstance.name = name.text
        SharingCenter.sharedInstance.password = password.text
        
        //Store credentials locally here
        let defaults = UserDefaults.standard
        
        /*
        defaults.setObject(email, forKey: "email")
        defaults.setObject(password.text!, forKey: "password")
        */
        //
        
        //YokweHelper.storeUser()
        
        FacebookHelper.riderGraphRequest(selfRider, completion: {(result)-> Void in
            SharingCenter.sharedInstance.rider = result
        })
        
        let notificationTypes : UIUserNotificationType = [.alert, .badge, .sound]
        let notificationSettings : UIUserNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        UIApplication.shared.registerForRemoteNotifications()
        
        SharingCenter.sharedInstance.locationManager = CLLocationManager()
        SharingCenter.sharedInstance.locationManager!.requestWhenInUseAuthorization()
        
        let protectedPage = self.storyboard?.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        
        present(protectedPage, animated: false, completion: nil)
        
    }
    
    //Formats the phone number as the user enters it
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
     
        checkFields()
        if textField == phone{
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            if length == 10{
                phoneIsValid = true
                
            }else{
                phoneIsValid = false
        
            }
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            checkFields()
            return false
            
        }else{
            
            checkFields()
            return true
        }
    }

}
