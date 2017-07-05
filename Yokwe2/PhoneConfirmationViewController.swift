//
//  PhoneConfirmationViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 9/15/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

class PhoneConfirmationViewController: UIViewController, UITextFieldDelegate {

    var phoneNumber:String?
    @IBOutlet weak var codeTextBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Confirm Phone Number"
        
        codeTextBox.keyboardType = .numberPad
        codeTextBox.isFirstResponder
        
    }
    
    func proceedToHomeScreen(){
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func continueTap(_ sender: AnyObject) {
        //See if code is valid on server
        let code = codeTextBox.text
        print(code!)
        
        //Call api
        YokweHelper.verifyCode(code!, number: phoneNumber!, completion: {(result) -> Void in
            let valid = result
            DispatchQueue.main.async(execute: {
                if valid{
                    SharingCenter.sharedInstance.phone = self.phoneNumber!
                    self.proceedToHomeScreen()
                }else{
                    //Notify user that code is wrong
                    self.errorNotification()
                }

            })
        })
        
    }
    
    func errorNotification(){
        let alertString = "Incorrect code"
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
