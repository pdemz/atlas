//
//  User.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 3/31/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation
import UIKit

class User{
    
    var aboutMe:String?
    var accessToken:String?
    var apnsToken:String?
    var email:String?
    var userID:String?
    var phone:String?
    var customerToken:String?
    var accountToken:String?
    var name:String?
    var education:String?
    
    init(json:NSDictionary){
        
        self.aboutMe = json.valueForKey("aboutMe") as? String
        self.accessToken = json.valueForKey("accesstoken") as? String
        self.apnsToken = json.valueForKey("apnsToken") as? String
        self.email = json.valueForKey("email") as? String
        self.userID = json.valueForKey("id") as? String
        self.phone = json.valueForKey("phone") as? String
        self.customerToken = json.valueForKey("customerToken") as? String
        self.accountToken = json.valueForKey("accountToken") as? String
        self.name = json.valueForKey("name") as? String
    }
    
}
