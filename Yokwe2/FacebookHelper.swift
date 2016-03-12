//
//  FacebookHelper.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 1/18/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class FacebookHelper{
    
    //Returns a driver with photo and name added to one passed in
    class func driverGraphRequest(driver:Driver, completion:(result:Driver)->Void){
        let params = ["fields": "id, first_name, email, picture.height(500)"]
        
        FBSDKGraphRequest(graphPath: driver.userID, parameters: params, tokenString: driver.accessToken, version: nil, HTTPMethod: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) == nil){
                let dict = result as! NSDictionary
                driver.name = dict.valueForKey("first_name") as? String
                print(dict.valueForKey("email"))
                
                let url = dict.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
                print(url)
                if let picURL = NSURL(string: url){
                    print(picURL)
                    if let data = NSData(contentsOfURL: picURL){
                        
                        driver.photo = UIImage(data: data)!
                        completion(result: driver)
                        
                    }
                }
            }
        })
    }
    
    //Returns a rider with photo and name added to the one passed in
    class func riderGraphRequest(rider:Rider, completion:(result:Rider)->Void){
        let params = ["fields": "id, first_name, email, picture.height(500)"]
        
        FBSDKGraphRequest(graphPath: rider.userID, parameters: params, tokenString: rider.accessToken, version: nil, HTTPMethod: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) == nil){
                let dict = result as! NSDictionary
                rider.name = dict.valueForKey("first_name") as? String
                let url = dict.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
                
                if let picURL = NSURL(string: url){
                    if let data = NSData(contentsOfURL: picURL){
                        rider.photo = UIImage(data: data)
                        completion(result: rider)
                    }
                }
            }
        })
    }
    
}