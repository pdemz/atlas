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
        let params = ["fields": "id, first_name, email, picture.height(500), education"]
        
        print("got into driverGraphRequest")
        
        //Don't try to add Facebook info if they don't have an access token
        if driver.accessToken == nil || driver.accessToken == "null"{
            driver.name = ""
            completion(result: driver)
        }
        
        FBSDKGraphRequest(graphPath: driver.userID, parameters: params, tokenString: driver.accessToken, version: nil, HTTPMethod: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) == nil){
                let dict = result as! NSDictionary
                driver.name = dict.valueForKey("first_name") as? String
                print(result)
                print(dict.valueForKey("email"))
                let educationList = dict.valueForKey("education") as? [NSDictionary]
                let school = educationList?.last
                var education = ""
                if let schoolName = school?.valueForKey("school")?.valueForKey("name") as? String{
                    education += schoolName
                }
                
                
                /* I think this is too much information
                if let schoolYear = school?.valueForKey("year")?.valueForKey("name") as? String{
                    education += " \(schoolYear)"
                }*/
                
                driver.education = education
                print(driver.education)
                
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
        let params = ["fields": "id, first_name, email, picture.height(500), education"]
        
        //Don't try to add Facebook info if they don't have an access token
        if rider.accessToken == nil || rider.accessToken == "null"{
            rider.name = ""
            completion(result: rider)
        }
        
        FBSDKGraphRequest(graphPath: rider.userID, parameters: params, tokenString: rider.accessToken, version: nil, HTTPMethod: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) == nil){
                let dict = result as! NSDictionary
                rider.name = dict.valueForKey("first_name") as? String
                let url = dict.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String
                
                let educationList = dict.valueForKey("education") as? [NSDictionary]
                let school = educationList?.last
                var education = ""
                if let schoolName = school?.valueForKey("school")?.valueForKey("name") as? String{
                    education += schoolName
                }
                
                /*if let schoolYear = school?.valueForKey("year")?.valueForKey("name") as? String{
                    education += " \(schoolYear)"
                }*/
                
                rider.education = education
                print(education)
                
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