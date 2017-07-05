//
//  SlideOutMenuViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 2/2/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit

class SlideOutMenuViewController: UITableViewController {
    
    
    @IBOutlet weak var modeCellText: UILabel!
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            //Present payment manager
            presentPayment()
            
        case 1:
            //Open profile with edit button
            presentProfile()
            
        case 2:
            //Open settings
            presentSettings()

        case 3:
            //Switch from riding to driving
            switchMode()
            
        default:
            self.revealViewController().revealToggle(animated: true)
        }
        self.revealViewController().revealToggle(animated: true)
    }
    
    func switchMode(){
        if SharingCenter.sharedInstance.mode == "driver"{
            SharingCenter.sharedInstance.mode = "rider"
            modeCellText.text = "Switch to Driving"
        }else{
            SharingCenter.sharedInstance.mode = "driver"
            modeCellText.text = "Switch to Riding"
        }
    }
    
    func presentSettings(){
        var settings = self.storyboard?.instantiateViewController(withIdentifier: "Settings") as! SettingsTableViewController
        settings = customizeVC(settings) as! SettingsTableViewController
        settings.title = "Settings"
        settings.phoneText = SharingCenter.sharedInstance.phone

        var navController = UINavigationController(rootViewController: settings)
        navController = UIHelper.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)
    }
    
    func presentPayment(){
        var paymentVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentManager") as! PaymentManagementController
        paymentVC = customizeVC(paymentVC) as! PaymentManagementController
        
        var navController = UINavigationController(rootViewController: paymentVC)
        navController = UIHelper.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)

        
    }
    
    func presentProfile(){
        var selfProfile = self.storyboard?.instantiateViewController(withIdentifier: "UserProfile") as! UserProfileViewController
        selfProfile = customizeVC(selfProfile) as! UserProfileViewController
        
        let editButton = UIBarButtonItem(image: UIImage(named: "Pencil"), style: UIBarButtonItemStyle.plain, target: selfProfile, action: "editProfile")
        
        //let editButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: selfProfile, action: "editProfile")
        selfProfile.navigationItem.rightBarButtonItem = editButton
        
        if let name = SharingCenter.sharedInstance.rider?.name{
            selfProfile.title = name
            selfProfile.educationText = SharingCenter.sharedInstance.rider?.education!
            print("This should be in your profile:")
            print(SharingCenter.sharedInstance.rider?.education!)
            selfProfile.photoImage = SharingCenter.sharedInstance.rider?.photo

        }
        
        if let aboutMeText = SharingCenter.sharedInstance.aboutMe{
            selfProfile.aboutMeText = aboutMeText
        }
        if let phone = SharingCenter.sharedInstance.phone{
            selfProfile.phoneText = phone
        }
        
        var navController = UINavigationController(rootViewController: selfProfile)
        navController = UIHelper.customizeNavController(navController)
        
        present(navController, animated: true, completion: nil)
    }
    
    func customizeNavController(_ navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.tintColor = colorHelper.orange
        navController.navigationBar.isTranslucent = false
        
        return navController
    }
    
    func customizeVC(_ vc:UIViewController) -> UIViewController{
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        
        //Dismiss button
        let dismissButton = UIBarButtonItem(image: UIImage(named: "Close"), style: UIBarButtonItemStyle.plain, target: vc, action: "closeView")
        vc.navigationItem.leftBarButtonItem = dismissButton

        return vc
    }
}
