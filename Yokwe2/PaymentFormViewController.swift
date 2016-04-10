//
//  PaymentForm.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 3/16/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import Stripe

class PaymentFormViewController: UIViewController, STPPaymentCardTextFieldDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardTextField.delegate = self
        emailTextField.delegate = self
        
        continueButton.tintColor = colorHelper.maroonOrange
        continueButton.enabled = false
        cardTextField.borderWidth = 0.5
        cardTextField.borderColor = UIColor.lightGrayColor()
        
    }
    
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        if emailTextField.text != "" && textField.valid{
            continueButton.enabled = true
        }else{
            continueButton.enabled = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if emailTextField.text != "" && cardTextField.valid{
            continueButton.enabled = true
        }else{
            continueButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func closeView(){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        let newCard = cardTextField.cardParams
        
        //Either get the token and save the card to server
        STPAPIClient.sharedClient().createTokenWithCard(newCard, completion: { (token, error) -> Void in
            var alertString:String?
            var okAction:UIAlertAction?
            if let error = error {
                print(error)
                //Create alert for error, and ask user to retry
                alertString = "There were errors processing your payment information. Please try again."
                okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
            }else if let token = token {
                YokweHelper.updatePaymentInfo(token.tokenId, email: self.emailTextField.text!)
                SharingCenter.sharedInstance.customerToken = token.tokenId
                
                print(token.tokenId)
                alertString = "Payment information stored successfully"
                okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            }
            if alertString != nil{
                let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(okAction!)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
}