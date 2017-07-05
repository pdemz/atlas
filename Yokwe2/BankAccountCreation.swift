//
//  BankAccountCreation.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 4/10/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class BankAccountCreation: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var routingNum: UITextField!
    @IBOutlet weak var accountNum: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for case let textField as UITextField in (self.view.subviews.first?.subviews.first?.subviews)!{
            textField.delegate = self
            
            if textField == routingNum || textField == accountNum{
                textField.keyboardType = UIKeyboardType.numberPad
            }
        }
    }
    
    func saveInfo() {
        if fieldsAreCorrectLength(){
            YokweHelper.addBankAccount(name.text!, email: email.text, accountNum: accountNum.text!, routingNum: routingNum.text!, completion: { (result) -> Void in
                
                var alertString:String?
                var okAction:UIAlertAction?
                
                if let resultString = result {
                    alertString = "Bank account added successfully"
                    print(resultString)
                    
                    okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    })
                    
                }
                else{
                    //Create alert for error, and ask user to retry
                    alertString = "There were errors processing your payment information. Please try again."
                    okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)                    })
                }
                
                if alertString != nil{
                    DispatchQueue.main.async(execute: {
                        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(okAction!)
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
            
        }else{
            print("sorry, charlie.")
        }
    }
    
    
    //Below code helps ensure info is entered correctly
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        var maxLength = 100
        
        let currentLength = textField.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = currentLength + lengthToAdd - lengthToReplace
        
        if textField == routingNum{
            maxLength = 9
        }else if textField == accountNum{
            maxLength = 12
        }else{
            return true
        }
        //print("newLength: \(newLength) maxLength: \(maxLength)")
        
        return newLength <= maxLength
    }
    
    func fieldsAreCorrectLength() -> Bool{
        for case let textField as UITextField in (self.view.subviews.first?.subviews.first?.subviews)!{
            if textField.text == ""{
                return false
            }else{
                var maxLength = 100
                
                if textField == routingNum{
                    maxLength = 9
                }else{
                    maxLength = (textField.text?.characters.count)!
                }
                
                if textField.text?.characters.count != maxLength{
                    return false
                }
            }
        }
        
        return true
    }
    
    func closeView(){
        let alertString = "You are able to drive, but we cannot pay money out to you until you add direct deposit information."
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
            self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
        })
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
