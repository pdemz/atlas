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
        
        self.aboutMe = json.value(forKey: "aboutMe") as? String
        self.accessToken = json.value(forKey: "accesstoken") as? String
        self.apnsToken = json.value(forKey: "apnsToken") as? String
        self.email = json.value(forKey: "email") as? String
        self.userID = json.value(forKey: "id") as? String
        self.phone = json.value(forKey: "phone") as? String
        self.customerToken = json.value(forKey: "customerToken") as? String
        self.accountToken = json.value(forKey: "accountToken") as? String
        self.name = json.value(forKey: "name") as? String
    }
    
}
