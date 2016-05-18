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
}

class TripDetails: UIViewController {

    var photoImage:UIImage?
    var nameText:String?
    var addedTimeText:String?
    var totalTimeText:String?
    var delegate:TripDetailsDelegate?
    
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
    
}
