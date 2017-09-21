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
    class func driverGraphRequest(_ driver:Driver, completion:@escaping (_ result:Driver)->Void){
        let params = ["fields": "id, first_name, email, picture.height(500), education"]
        
        print("got into driverGraphRequest")
        
        //Don't try to add Facebook info if they don't have an access token
        if driver.accessToken == nil || driver.accessToken == "null"{
            driver.photo = UIImage(named: "noUserPhoto")
            completion(driver)
        }
        
        FBSDKGraphRequest(graphPath: driver.userID, parameters: params, tokenString: driver.accessToken, version: nil, httpMethod: nil).start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) == nil){
                let dict = result as! NSDictionary
                driver.name = dict.value(forKey: "first_name") as? String
                let educationList = dict.value(forKey: "education") as? [NSDictionary]
                let school = educationList?.last
                var education = ""
                if let schoolName = (school?.value(forKey: "school") as AnyObject).value(forKey: "name") as? String{
                    education += schoolName
                }
                
                
                /* I think this is too much information
                if let schoolYear = school?.valueForKey("year")?.valueForKey("name") as? String{
                    education += " \(schoolYear)"
                }*/
                
                driver.education = education
                
                let url = ((dict.value(forKey: "picture") as AnyObject).object(forKey: "data") as AnyObject).object(forKey: "url") as! String
                if let picURL = URL(string: url){
                    if let data = try? Data(contentsOf: picURL){
                        
                        driver.photo = UIImage(data: data)!
                        completion(driver)
                        
                    }
                }
            }
        })
    }
    
    //Returns a rider with photo and name added to the one passed in
    class func riderGraphRequest(_ rider:Rider, completion:@escaping (_ result:Rider)->Void){
        let params = ["fields": "id, first_name, email, picture.height(500), education"]
        
        //Don't try to add Facebook info if they don't have an access token
        if rider.accessToken == nil || rider.accessToken == "null"{
            rider.photo = UIImage(named: "noUserPhoto")
            completion(rider)
        }
        
        FBSDKGraphRequest(graphPath: rider.userID, parameters: params, tokenString: rider.accessToken, version: nil, httpMethod: nil).start(completionHandler: { (connection, result, error) -> Void in
            
            if ((error) == nil){
                let dict = result as! NSDictionary
                rider.name = dict.value(forKey: "first_name") as? String
                let url = ((dict.value(forKey: "picture") as AnyObject).object(forKey: "data") as AnyObject).object(forKey: "url") as! String
                
                let educationList = dict.value(forKey: "education") as? [NSDictionary]
                let school = educationList?.last
                var education = ""
                if let schoolName = (school?.value(forKey: "school") as AnyObject).value(forKey: "name") as? String{
                    education += schoolName
                }
                
                /*if let schoolYear = school?.valueForKey("year")?.valueForKey("name") as? String{
                    education += " \(schoolYear)"
                }*/
                
                rider.education = education
                
                if let picURL = URL(string: url){
                    if let data = try? Data(contentsOf: picURL){
                        rider.photo = UIImage(data: data)
                        completion(rider)
                    }
                }
            }
        })
    }
    
}
