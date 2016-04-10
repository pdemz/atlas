//
//  Driver.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/4/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit

class Driver {
    
    // MARK: Properties
    
    var name: String?
    var photo: UIImage?
    var mutualFriends: String?
    var fareEstimate: String?
    var eta: String?
    var userID: String?
    var accessToken: String?
    var addedTime: Double?
    var origin: String?
    var destination: String?
    var phone: String?
    var aboutMe: String?
    var price: String?
    
    init(name: String?, photo: UIImage?, mutualFriends: String?, fareEstimate: String?, eta:String?, userID:String?, accessToken:String?, addedTime:Double?){
        
        self.name = name
        self.photo = photo
        self.mutualFriends = mutualFriends
        self.fareEstimate = fareEstimate
        self.eta = eta
        self.userID = userID
        self.accessToken = accessToken
        self.addedTime = addedTime
    }
    
    
    
}
