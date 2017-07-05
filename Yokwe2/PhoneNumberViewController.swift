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
        phone.keyboardType = .phonePad

        continueButton.alpha = 0.5
        continueButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Enter Phone Number"
        
        self.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        /*
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: self, action: "closeView")
        self.navigationItem.leftBarButtonItem = dismissButton
 */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.title = ""
    }
    
    @IBAction func continuePress(_ sender: AnyObject) {
        proceedToHomeScreen()
    }
    
    //Formats the phone number as the user enters it
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
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
                continueButton.alpha = 1
                continueButton.isEnabled = true
            }else{
                continueButton.alpha = 0.5
                continueButton.isEnabled = false
            }
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            return false
            
        }else{
            return true
        }
    }
    
    func proceedToHomeScreen(){
        YokweHelper.requestVerificationCode(phone.text!)
 
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhoneConfirmation") as! PhoneConfirmationViewController
        
        vc.phoneNumber = phone.text!
        self.show(vc, sender: self)
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func closeView(){
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        dismiss(animated: true, completion: nil)
        
    }
}
