//
//  TripStatusObject.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 10/2/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation

class TripStatusObject{
    var to:String?
    var from:String?
    var status:String?
    var mode:String?
    var tripID:Int?
    
    init(newTo:String, newFrom:String, newStatus:String, newMode:String){
        to = newTo
        from = newFrom
        status = newStatus
        mode = newMode
        
    }
    
    
}
