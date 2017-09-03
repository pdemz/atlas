//
//  SlideOutMenuContainingViewController.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 8/13/17.
//  Copyright © 2017 Pierce Demarreau. All rights reserved.
//

import UIKit

class SlideOutMenuContainingViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var modeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = SharingCenter.sharedInstance.rider?.name{
            
            nameLabel.text = name
        }
        
        userImage.image = SharingCenter.sharedInstance.rider?.photo
        userImage.layer.cornerRadius = userImage.frame.height/2
        
        initializeMode()
        /*DispatchQueue.main.async() {
            self.initializeMode()
        }*/
        
    }
    
    @IBAction func switchModeButtonTap(_ sender: Any) {
        switchMode()
        
    }
    
    //Switch from riding to driving or vice versa and update the button
    func switchMode(){
        if SharingCenter.sharedInstance.mode == "driver"{
            SharingCenter.sharedInstance.mode = "rider"
            modeButton.setTitle("Switch to Driving", for: .normal)
            
        }else{
            SharingCenter.sharedInstance.mode = "driver"
            modeButton.setTitle("Switch to Riding", for: .normal)
            
        }
        
        self.revealViewController().revealToggle(animated: true)
    }
    
    //Update the button label to reflect current mode
    func initializeMode(){
        if SharingCenter.sharedInstance.mode == "driver"{
            modeButton.setTitle("Switch to Riding", for: .normal)
            
        }else{
            modeButton.setTitle("Switch to Driving", for: .normal)
            
        }
        
        
    }

}
