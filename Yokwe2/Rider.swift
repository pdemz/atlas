//
//  Rider.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/29/15.
//  Copyright © 2015 Pierce Demarreau. All rights reserved.
//

import UIKit

class Rider{
    
    // MARK: Properties
    
    var name: String?
    var photo: UIImage?
    var mutualFriends: String?
    var fareEstimate: String?
    var addedTime: String?
    var origin: String?
    var destination: String?
    var userID: String?
    var accessToken:String?
    var phone:String?
    var aboutMe:String?
    var price:String?
    
    init(name: String?, origin: String?, destination: String?, photo: UIImage?, mutualFriends: String?, fareEstimate: String?, addedTime:String?, userID:String?, accessToken:String?){
        
        self.name = name
        self.photo = photo
        self.mutualFriends = mutualFriends
        self.fareEstimate = fareEstimate
        self.addedTime = addedTime
        self.origin = origin
        self.destination = destination
        self.userID = userID
        self.accessToken = accessToken
    }

}
