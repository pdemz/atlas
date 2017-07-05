//
//  UIHelper.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 7/10/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation

class UIHelper{
    class func customizeNavController(_ navController: UINavigationController) -> UINavigationController{
        navController.navigationBar.barStyle = .black
        navController.navigationBar.tintColor = UIColor.white
        navController.navigationBar.barTintColor = colorHelper.orange
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
