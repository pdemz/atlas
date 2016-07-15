//
//  UIHelper.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 7/10/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation

class UIHelper{
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