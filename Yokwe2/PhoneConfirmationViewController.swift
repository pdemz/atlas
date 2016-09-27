//
//  PhoneConfirmationViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 9/15/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

class PhoneConfirmationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var codeTextBox: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Confirm Phone Number"
        
        codeTextBox.isFirstResponder()
        
    }
    
    func proceedToHomeScreen(){
        let homeScreen = self.storyboard?.instantiateViewControllerWithIdentifier("SWRevealViewController") as! SWRevealViewController
         
         presentViewController(homeScreen, animated: false, completion: nil)
        
        
    }
    
    @IBAction func continueTap(sender: AnyObject) {
        //See if code is valid on server
        let code = codeTextBox.text
        print(code!)
        
        //Call api
        YokweHelper.verifyCode(code!, completion: {(result) -> Void in
            let valid = result
            dispatch_async(dispatch_get_main_queue(), {
                if valid{
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
        let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
        let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
