//
//  RideOrDriveViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 6/6/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

class RideOrDriveViewController: UIViewController {
    @IBAction func ride(sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "rider"
        
        if SharingCenter.sharedInstance.customerToken == nil{
            //Ask if they want to submit payment info now or later, if they select yes, open the payment view controller, otherwise do nothing
            let alertString = "You'll have to enter a credit card before you can get a ride. Want to do that now?"
            let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                self.presentCustomerForm()
                
            })
            
            let cancelAction = UIAlertAction(title: "Nah, I'll do it later", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                self.dismissViewControllerAnimated(true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    @IBAction func drive(sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "driver"
        
        if SharingCenter.sharedInstance.accountToken == nil{
            //Ask if they want to submit personal info and payment info now or later
            let alertString = "You'll have to enter some personal info before we can legally allow you to drive with us. Want to take care of that now?"
            let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                self.presentDriverForm()
                
            })
            
            let cancelAction = UIAlertAction(title: "Nah, I'll do it later", style: UIAlertActionStyle.Default, handler: {(ACTION) in
                self.dismissViewControllerAnimated(true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    func presentCustomerForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentForm") as! PaymentFormViewController
        vc = RideOrDriveViewController.customizeVC(vc) as! PaymentFormViewController
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = RideOrDriveViewController.customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func presentDriverForm(){
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("DriverAccountCreation") as! DriverAccountCreationViewController
        vc = RideOrDriveViewController.customizeVC(vc) as! DriverAccountCreationViewController
        vc.title = "Create Driver Account"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = RideOrDriveViewController.customizeNavController(navController)
        
        presentViewController(navController, animated: true, completion: nil)
    }
    
    class func customizeNavController(navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.translucent = false
        
        return navController
    }
    
    class func customizeVC(vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.Plain, target: vc, action: "closeView")
        vc.navigationItem.leftBarButtonItem = dismissButton
        
        //Save button
        let barSaveButton = UIBarButtonItem(barButtonSystemItem: .Done, target: vc, action: "saveInfo")
        vc.navigationItem.rightBarButtonItem = barSaveButton
        
        return vc
    }
    
    
}
