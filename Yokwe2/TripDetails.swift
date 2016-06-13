//
//  TripDetails.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 5/13/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import UIKit
import GoogleMaps

protocol TripDetailsDelegate {
    func pressedNavigate()
    func pressedCancel()
    func tappedPhoto()
    func tappedBackground()
}

class TripDetails: UIViewController {

    var photoImage:UIImage?
    var nameText:String?
    var addedTimeText:String?
    var totalTimeText:String?
    var delegate:TripDetailsDelegate?
    var phoneText:String?
    
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var navigate: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var addedTime: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        
        // Do any additional setup after loading the view.
        photo.layer.masksToBounds = false
        photo.layer.cornerRadius = photo.frame.height/2
        photo.clipsToBounds = true
        
        price.adjustsFontSizeToFitWidth = true
        totalTime.adjustsFontSizeToFitWidth = true
        addedTime.adjustsFontSizeToFitWidth = true
        
    }

    @IBAction func tappedBackground(sender: AnyObject) {
        print("background button tapped")
        self.delegate?.tappedBackground()
    }
    
    @IBAction func pressedNavigate(sender: AnyObject) {
        self.delegate?.pressedNavigate()
        
    }
    
    @IBAction func pressedCancel(sender: AnyObject) {
        self.delegate?.pressedCancel()
        
    }
    
    @IBAction func tappedPhoto(sender: AnyObject) {
        self.delegate?.tappedPhoto()
        
    }
    
    @IBAction func openMessenger(sender: AnyObject) {
        if phoneText != nil && phoneText != ""{
            let number = phoneText!.stringByReplacingOccurrencesOfString("(", withString: "").stringByReplacingOccurrencesOfString(") ", withString: "").stringByReplacingOccurrencesOfString("-", withString: "")
            let url = "sms:\(number)"
            UIApplication.sharedApplication().openURL(NSURL(string: url)!)
            
        }


    }
    
}
