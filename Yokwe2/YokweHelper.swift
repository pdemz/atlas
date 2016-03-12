//
//  YokweHelper.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 1/18/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import UIKit

class YokweHelper{
    
    //Returns a list of drivers given a rider
    class func getDriverList(completion:(result:[Driver])->Void){
        
        //Main part of address
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "rideRequest"
        let start = SharingCenter.sharedInstance.start.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let dest = SharingCenter.sharedInstance.destination.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let apnsToken = SharingCenter.sharedInstance.apnsToken
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&origin=\(start)&destination=\(dest)&type=\(type)&accessToken=\(accessToken)&apnsToken=\(apnsToken)"
        print(postString)
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            //userID;accessToken_
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            let driverStringList = responseString.componentsSeparatedByString("_")
            print(responseString)
            var driverList:[Driver] = [Driver]()
            for driver in driverStringList{
                if driver != ""{
                    var newb = driver.componentsSeparatedByString(";")
                    driverList.append(Driver(name: nil, photo: nil, mutualFriends: newb[3], fareEstimate: nil, eta: nil, userID: newb[0], accessToken: newb[1], addedTime: Double(newb[2])))
                }
            }
            
            completion(result: driverList)
        }
        
        task.resume()
    }
    
    //returns a list of riders given a driver
    class func getRiderList(completion:(result:[Rider])->Void){
        
        //Main part of address
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "driveRequest"
        let start = SharingCenter.sharedInstance.start.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let dest = SharingCenter.sharedInstance.destination.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let apnsToken = SharingCenter.sharedInstance.apnsToken
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&origin=\(start)&destination=\(dest)&type=\(type)&accessToken=\(accessToken)&limit=30&apnsToken=\(apnsToken)"
        print(postString)
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            //id;accessToken;origin;destination;addedTime_
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!

            let riderStringList = responseString.componentsSeparatedByString("_")
            var riderList:[Rider] = [Rider]()
            for rider in riderStringList{
                if rider != ""{
                    var newb = rider.componentsSeparatedByString(";")
                    print("newbrider: \(responseString)")
                    riderList.append(Rider(name: nil, origin: newb[2], destination: newb[3], photo: nil, mutualFriends: newb[5], fareEstimate: nil, addedTime: newb[4], userID: newb[0], accessToken: newb[1]))
                }
            }
            
            completion(result: riderList)
            
        }
        
        task.resume()
    }
    
    //Checks if user has received any drive/ride requests
     //If not nil, will return type;userID;accessToken;origin;destination;driver.available;addedTime
    class func update(completion:(result:[String]?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "update"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            if responseString != "nothing"{
                let resultsArray = responseString.componentsSeparatedByString(";")
                completion(result: resultsArray)
            }
            else{
                completion(result: nil)
            }
            
            
        }
        task.resume()
    }
    
    //Store/update user
    class func storeUser(){
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "storeUser"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let apnsToken = SharingCenter.sharedInstance.apnsToken
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&apnsToken=\(apnsToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        }
        task.resume()
    }

    //Store aboutMe in DB
    class func storeAboutMe(aboutMe:String){
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "updateProfile"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&aboutMe=\(aboutMe)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        }
        task.resume()
    }
    
    //Get about me from db
    class func getProfile(completion:(result: String?)->Void){
        //Gets about me and phone number -- for when the user views their profile
        
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getProfile"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            if responseString != "null"{
                print("profile:")
                print(responseString)
                completion(result: responseString)
            }
            else{
                completion(result: nil)
            }
            
            
        }
        task.resume()
    }
    
    class func doesUserExist(completion:(result: Bool)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "doesUserExist"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            if responseString == "true"{
                completion(result: true)
                
            }else{
                completion(result: false)
                
            }
            
        }
        task.resume()
        
    }
    
    //Store phone number
    class func storePhone(phone:String){
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "updatePhone"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&phone=\(phone)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        }
        task.resume()
    }
    
    //Get phone number from db
    class func getPhone(completion:(result: String?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getPhone"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            if responseString != "NULL"{
                completion(result: responseString)
            }
            else{
                completion(result: nil)
            }
            
            
        }
        task.resume()
    }
    
    //Called after a rider is selected by a driver
    class func riderSelection(riderID:String, addedTime:String){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "riderSelection"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&riderID=\(riderID)&addedTime=\(addedTime)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        }
        task.resume()
    }
    
    //Called after a driver is selected by a rider
    class func driverSelection(driverID:String, addedTime:String){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "driverSelection"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&driverID=\(driverID)&addedTime=\(addedTime)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        }
        task.resume()
    }
    
    //Called when a request is accepted
    class func acceptRequest(requesterID:String, requestType:String){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "accept"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&requesterID=\(requesterID)&requestType=\(requestType)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        }
        task.resume()
    }
    
    //Called when driver rejects a request from a rider
    class func rideReject(requesterID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "rideReject"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&requesterID=\(requesterID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        }
        task.resume()
    }
    
    //Called when rider rejects a request from a driver
    class func driveReject(requesterID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "driveReject"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&requesterID=\(requesterID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        }
        task.resume()
    }
    
    //Called when user ends an active trip
    class func endTrip(riderID:String, driverID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "end"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)&riderID=\(riderID)&driverID=\(driverID)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        }
        task.resume()
    }
    
    //Fetches trips, pending responses, or any requests
    class func getUpdate(completion:(result: NSDictionary)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/YokweServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "update"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            print("update: \(responseString)")
            
            do {
                if let jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary{
                    print("json: \(jsonResults)")
                    completion(result: jsonResults)
                }
                
            } catch {
                // failure
                print("Fetch failed: \((error as NSError).localizedDescription)")
            }
            
        }
        task.resume()
    }
    
    //Get phone number from db with user ID and accessToken
    class func getPhoneWithID(userID:String, accessToken:String, completion:(result: String?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getPhone"
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            if responseString != "NULL"{
                completion(result: responseString)
            }
            else{
                completion(result: nil)
            }
            
            
        }
        task.resume()
    }
    
    //Get about me from db with ID and accessToken
    class func getProfileWithID(userID:String, accessToken:String, completion:(result: String?)->Void){
        //Gets about me and phone number -- for when the user views their profile
        
        let addr = NSURL(string: "https://www.yokweapp.com/ProfileServlet")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getProfile"
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            if responseString != "null"{
                print("profile:")
                print(responseString)
                completion(result: responseString)
            }
            else{
                completion(result: nil)
            }
            
            
        }
        task.resume()
    }


    
}
