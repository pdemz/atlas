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
        phone.keyboardType = .numberPad
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            
            //Go to title view controller
            goToLoginScreen()
        }
    }
    
    func goToLoginScreen(){
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let initialViewController = mainStoryBoard.instantiateViewController(withIdentifier: "TitularViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = initialViewController
        
    }
    
    //Formats the phone number as the user enters it
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("editing text field")
        //Formats the phone number as the user enters it
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
                canClose = true
            }else{
                canClose = false
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            
            return false
            
        }else{
            return true
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func closeView(){
        if canClose{
            if phone.text! != phoneText{
                SharingCenter.sharedInstance.phone = phone.text!
                YokweHelper.storeUser()
            }
            dismiss(animated: true, completion: nil)
        }
    }

}
