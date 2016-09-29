//
//  AccountCreationViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 3/29/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class DriverAccountCreationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var first: UITextField!
    @IBOutlet weak var last: UITextField!
    @IBOutlet weak var month: UITextField!
    @IBOutlet weak var day: UITextField!
    @IBOutlet weak var year: UITextField!
    @IBOutlet weak var ssn: UITextField!
    @IBOutlet weak var street: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var zip: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for case let textField as UITextField in (self.view.subviews.first?.subviews.first?.subviews)!{
            textField.delegate = self
            
            if textField == month || textField == day || textField == year || textField == ssn || textField == zip{
                textField.keyboardType = UIKeyboardType.NumberPad
            }
        }
    }
    
    func saveInfo() {
        if fieldsAreCorrectLength(){
            YokweHelper.createStripeAccount(first.text!, lastName: last.text!, day: day.text!, month: month.text!, year: year.text!, line1: street.text!.stringByReplacingOccurrencesOfString(" ", withString: "+"), line2: nil, city: city.text!, state: state.text!, zip: zip.text!, last4: ssn.text!, completion: { (result) -> Void in
                
                var alertString:String?
                var okAction:UIAlertAction?
                
                if let token = result {
                    SharingCenter.sharedInstance.accountToken = token
                    print("New account token: \(token)")
                    
                    alertString = "Account created successfully"
                    okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                        self.presentBankForm()
                    })
                    
                }
                else{
                    //Create alert for error, and ask user to retry
                    alertString = "There were errors processing your payment information. Please try again."
                    okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                        self.presentBankForm()
                    })
                }
                
                if alertString != nil{
                    dispatch_async(dispatch_get_main_queue(), {
                        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(okAction!)
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                }
            })

        }else{
            print("sorry, charlie.")
        }
    }
    
    
    //Below code helps ensure info is entered correctly
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        
        var maxLength = 100
        
        let currentLength = textField.text?.characters.count ?? 0
        let lengthToAdd = string.characters.count
        let lengthToReplace = range.length
        
        let newLength = currentLength + lengthToAdd - lengthToReplace
        
        if textField == month{
            maxLength = 2
        }else if textField == day{
            maxLength = 2
        }else if textField == state{
            maxLength = 2
        }else if textField == ssn{
            maxLength = 4
        }else if textField == year{
            maxLength = 4
        }else if textField == zip{
            maxLength = 5
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
                
                if textField == month{
                    maxLength = 2
                }else if textField == day{
                    maxLength = 2
                }else if textField == state{
                    maxLength = 2
                }else if textField == ssn{
                    maxLength = 4
                }else if textField == year{
                    maxLength = 4
                }else if textField == zip{
                    maxLength = 5
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
    
    func presentBankForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("BankAccountCreation") as! BankAccountCreation
        vc = customizeVC(vc) as! BankAccountCreation
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = customizeNavController(navController)
        
        navController.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = false
        
        return navController
    }
    
    func customizeVC(vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: vc, action: #selector(DriverAccountCreationViewController.closeView))
        vc.navigationItem.leftBarButtonItem = dismissButton
        
        //Save button
        let barSaveButton = UIBarButtonItem(barButtonSystemItem: .Done, target: vc, action: #selector(DriverAccountCreationViewController.saveInfo))
        vc.navigationItem.rightBarButtonItem = barSaveButton
        
        return vc
    }
    
    func closeView(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
