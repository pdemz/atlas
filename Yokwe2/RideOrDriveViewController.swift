//
//  RideOrDriveViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 6/6/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

class RideOrDriveViewController: UIViewController {
    @IBAction func ride(_ sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "rider"
        
        if SharingCenter.sharedInstance.customerToken == nil{
            //Ask if they want to submit payment info now or later, if they select yes, open the payment view controller, otherwise do nothing
            let alertString = "You can search for drivers heading your way, but you won't be able to request rides from them until you enter a credit card. Want to do that now?"
            let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                self.presentCustomerForm()
                
            })
            
            let cancelAction = UIAlertAction(title: "Nah, I'll do it later", style: UIAlertActionStyle.default, handler: {(ACTION) in
                self.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func drive(_ sender: AnyObject) {
        SharingCenter.sharedInstance.mode = "driver"
        
        if SharingCenter.sharedInstance.accountToken == nil{
            //Ask if they want to submit personal info and payment info now or later
            let alertString = "You'll have to enter some personal info before we can legally allow you to drive with us. If not, you'll still be able to search for riders, you just won't be able to drive them."
            let alert = UIAlertController(title: "", message: alertString, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let okAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {(ACTION) in
                self.presentDriverForm()
                
            })
            
            let cancelAction = UIAlertAction(title: "Nah, I'll do it later", style: UIAlertActionStyle.default, handler: {(ACTION) in
                self.dismiss(animated: true, completion: nil)
                
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func presentCustomerForm(){
        var vc = self.storyboard?.instantiateViewController(withIdentifier: "PaymentForm") as! PaymentFormViewController
        vc = RideOrDriveViewController.customizeVC(vc) as! PaymentFormViewController
        vc.title = "Payment Info"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = RideOrDriveViewController.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)
    }
    
    func presentDriverForm(){
        var vc = self.storyboard?.instantiateViewController(withIdentifier: "DriverAccountCreation") as! DriverAccountCreationViewController
        vc = RideOrDriveViewController.customizeVC(vc) as! DriverAccountCreationViewController
        vc.title = "Create Driver Account"
        
        var navController = UINavigationController(rootViewController: vc)
        navController = RideOrDriveViewController.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)
    }
    
    class func customizeNavController(_ navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.isTranslucent = false
        
        return navController
    }
    
    class func customizeVC(_ vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.plain, target: vc, action: "closeView")
        vc.navigationItem.leftBarButtonItem = dismissButton
        
        //Save button
        let barSaveButton = UIBarButtonItem(barButtonSystemItem: .done, target: vc, action: "saveInfo")
        vc.navigationItem.rightBarButtonItem = barSaveButton
        
        return vc
    }
    
    
}
