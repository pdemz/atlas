//
//  SettingsTableViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/8/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var logout: UILabel!
    @IBOutlet weak var phone: UITextField!
    
    var phoneText:String?
    var canClose = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        phone.delegate = self
        phone.text = phoneText
        phone.keyboardType = .NumberPad
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 1{
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            //Go to title view controller
            goToLoginScreen()
        }
    }
    
    func goToLoginScreen(){
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let initialViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("TitularViewController")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController = initialViewController
        
    }
    
    //Formats the phone number as the user enters it
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("editing text field")
        //Formats the phone number as the user enters it
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
                canClose = true
            }else{
                canClose = false
            }
            
            let remainder = decimalString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            
            return false
            
        }else{
            return true
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func closeView(){
        if canClose{
            if phone.text! != phoneText{
                SharingCenter.sharedInstance.phone = phone.text!
                YokweHelper.storeUser()
            }
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
