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

    var canContinue = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardTextField.delegate = self
        emailTextField.delegate = self
        
        cardTextField.borderWidth = 0.5
        cardTextField.borderColor = UIColor.lightGray
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        if textField.valid{
            canContinue = true
        }else{
            canContinue = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if cardTextField.valid{
            canContinue = true
        }else{
            canContinue = false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func closeView(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        let newCard = cardTextField.cardParams
        
        //Either get the token and save the card to server
        STPAPIClient.shared().createToken(withCard: newCard, completion: { (token, error) -> Void in
            var alertString:String?
            var okAction:UIAlertAction?
            if let error = error {
                print(error)
                //Create alert for error, and ask user to retry
                alertString = "There were errors processing your payment information. Please try again."
                okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                    self.dismiss(animated: true, completion: nil)
                })
                
            }else if let token = token {
                YokweHelper.updatePaymentInfo(token.tokenId, email: self.emailTextField.text!)
                SharingCenter.sharedInstance.customerToken = token.tokenId
                
                print(token.tokenId)
                
                alertString = "Payment information stored successfully"
                okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                    self.dismiss(animated: true, completion: nil)
                })
                
            }
            if alertString != nil{
                let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(okAction!)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func saveInfo() {
        
        //Get source params from card
        let newCard = cardTextField.cardParams
        let sourceParams = STPSourceParams.cardParams(withCard: newCard)
        
        if canContinue{
            
            //get the token and save the card to the stripe server
            STPAPIClient.shared().createSource(with: sourceParams, completion: { (source, error) in
                var alertString:String?
                var okAction:UIAlertAction?
                
                print("checkpoint 1")
                
                //Check for any errors
                if let error = error {
                    print(error)
                    
                    //Create alert for error, and ask user to retry
                    alertString = "There were errors processing your payment information. Please try again."
                    okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    print("checkpoint 2")
                    
                //If successful, store the information
                }else if let s = source, s.flow == .none && s.status == .chargeable {
                    YokweHelper.updatePaymentInfo(s.stripeID, email: self.emailTextField.text!)
                    SharingCenter.sharedInstance.customerToken = s.stripeID
                    
                    print(s.stripeID)
                    
                    alertString = "Payment information stored successfully"
                    okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                }
                
                if alertString != nil{
                    let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(okAction!)
                    self.present(alert, animated: true, completion: nil)
                }
            })
            
        }
    }

    
}
