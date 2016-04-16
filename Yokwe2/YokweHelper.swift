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
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "rideRequest"
        let start = SharingCenter.sharedInstance.start.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let dest = SharingCenter.sharedInstance.destination.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let userID = FBSDKAccessToken.currentAccessToken().userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&origin=\(start)&destination=\(dest)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            //userID;accessToken_
            if let responseString = String(data: data!, encoding: NSUTF8StringEncoding){
                let driverStringList = responseString.componentsSeparatedByString("_")
                print("responseString \(responseString)")
                
                var driverList:[Driver] = [Driver]()
                for driver in driverStringList{
                    if driver != "" && responseString != "null\n"{
                        var newb = driver.componentsSeparatedByString(";")
                        let newDriver = Driver(name: nil, photo: nil, mutualFriends: newb[3], fareEstimate: nil, eta: nil, userID: newb[0], accessToken: newb[1], addedTime: Double(newb[2]))
                        newDriver.price = newb[4]
                        print(newb[4])
                        driverList.append(newDriver)
                    }
                }
                completion(result: driverList)

            }
            
        }
        
        task.resume()
    }
    
    //returns a list of riders given a driver
    class func getRiderList(completion:(result:[Rider])->Void){
        
        //Main part of address
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "driveRequest"
        let start = SharingCenter.sharedInstance.start.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let dest = SharingCenter.sharedInstance.destination.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&origin=\(start)&destination=\(dest)&type=\(type)&accessToken=\(accessToken)&limit=30"
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
            if let responseString = String(data: data!, encoding: NSUTF8StringEncoding){
                let riderStringList = responseString.componentsSeparatedByString("_")
                var riderList:[Rider] = [Rider]()
                
                for rider in riderStringList{
                    if rider != "" && rider.containsString(";"){
                        var newb = rider.componentsSeparatedByString(";")
                        let newRider = Rider(name: nil, origin: newb[2], destination: newb[3], photo: nil, mutualFriends: newb[5], fareEstimate: nil, addedTime: newb[4], userID: newb[0], accessToken: newb[1])
                        newRider.price = newb[6]
                        riderList.append(newRider)
                        
                    }
                }
                completion(result: riderList)
                
            }
        
        }
        
        task.resume()
    }
    
    //Checks if user has received any drive/ride requests
     //If not nil, will return type;userID;accessToken;origin;destination;driver.available;addedTime
    class func update(completion:(result:[String]?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "update"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)"
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
    
    //Checks if user has received any drive/ride requests
    //If not nil, will return type;userID;accessToken;origin;destination;driver.available;addedTime
    class func getUser(completion:(result:User?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getUser"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        print("uid")
        print(userID!)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: nil)
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            
            print(responseString!)
            
            if responseString != nil && responseString != ""{

                print("response \(responseString)")
                do {
                    if let jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary{
                        print("json: \(jsonResults)")
                        let uu = User(json: jsonResults)
                        completion(result: uu)
                    }
                    
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                    completion(result: nil)
                }
            }
            else{
                completion(result: nil)
            }
            
            
        }
        task.resume()
    }
    
    //Store payment info
    class func updatePaymentInfo(token:String, email:String){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "updatePaymentInfo"
        let userID = SharingCenter.sharedInstance.userID
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&token=\(token)&email=\(email)"
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
    
    //Create stripe account
    class func createStripeAccount(firstName:String, lastName:String, day:String, month:String,year:String,
                                 line1:String, line2:String?, city:String, state:String, zip:String, last4:String, completion:(result:String?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "createStripeAccount"
        let userID = FBSDKAccessToken.currentAccessToken().userID
        
        let postString = "userID=\(userID)&type=\(type)&firstName=\(firstName)&lastName=\(lastName)" +
        "&day=\(day)&month=\(month)&year=\(year)&line1=\(line1)&city=\(city)&state=\(state)&zip=\(zip)&last4=\(last4)"
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            if let response = String(data: data!, encoding: NSUTF8StringEncoding){
                completion(result: response)
            }
            
            completion(result: nil)
            
        }
        task.resume()
    }
    
    class func addBankAccount(name:String, email:String?, accountNum:String, routingNum:String, completion:(result:String?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "addBankAccount"
        let userID = FBSDKAccessToken.currentAccessToken().userID
        
        var postString = "userID=\(userID)&type=\(type)&name=\(name)&accountNum=\(accountNum)&routingNum=\(routingNum)"
        
        //Email is optional - check if it is null
        if let emailString = email{
            postString += "&email=\(emailString)"
        }
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            if let response = String(data: data!, encoding: NSUTF8StringEncoding){
                if response != "null"{
                    completion(result: response)
                }
            }
            
            completion(result: nil)
            
        }
        task.resume()
    }
    
    //Store/update user
    //Verbose, but simple - and probably the least amount of code for the job
    class func storeUser(){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        var postString = "type=storeUser"
        if let userID = SharingCenter.sharedInstance.userID{
            postString += "&userID=\(userID)"
        }
        if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString{
            postString += "&accessToken=\(accessToken)"
        }
        if let apnsToken = SharingCenter.sharedInstance.apnsToken{
            postString += "&apnsToken=\(apnsToken)"
        }
        if let aboutMe = SharingCenter.sharedInstance.aboutMe{
            postString += "&aboutMe=\(aboutMe)"
        }
        if let phone = SharingCenter.sharedInstance.phone{
            postString += "&phone=\(phone)"
        }
        if let accountToken = SharingCenter.sharedInstance.accountToken{
            postString += "&accountToken=\(accountToken)"
            
        }
        if let email = SharingCenter.sharedInstance.email{
            postString += "&email=\(email)"

        }
        
        print("post string: \(postString)")
        
        request.HTTPMethod = "POST"
        
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
    
    //Store/update user
    class func storeUser(user:User){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        var postString = "type=storeUser"
        if let userID = SharingCenter.sharedInstance.userID{
            postString += "&userID=\(userID)"
        }
        if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString{
            postString += "&accessToken=\(accessToken)"
        }
        if let apnsToken = SharingCenter.sharedInstance.apnsToken{
            postString += "&apnsToken=\(apnsToken)"
        }
        if let aboutMe = SharingCenter.sharedInstance.aboutMe{
            postString += "&aboutMe=\(aboutMe)"
        }
        if let phone = SharingCenter.sharedInstance.phone{
            postString += "&phone=\(phone)"
        }

        
        request.HTTPMethod = "POST"
        
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
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "updateProfile"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&aboutMe=\(aboutMe)"
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
        
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getProfile"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "doesUserExist"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "updatePhone"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&phone=\(phone)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getPhone"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)"
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
    class func riderSelection(riderID:String, addedTime:String, price:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "riderSelection"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&riderID=\(riderID)&addedTime=\(addedTime)&price=\(price)"
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
    class func driverSelection(driverID:String, addedTime:String, price:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "driverSelection"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&driverID=\(driverID)&addedTime=\(addedTime)&price=\(price)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "accept"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&requesterID=\(requesterID)&requestType=\(requestType)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "rideReject"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&requesterID=\(requesterID)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "driveReject"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&requesterID=\(requesterID)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "end"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)&riderID=\(riderID)&driverID=\(driverID)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "update"
        let userID = SharingCenter.sharedInstance.userID
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString

        request.HTTPMethod = "POST"
        let postString = "userID=\(userID!)&type=\(type)&accessToken=\(accessToken)"
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
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
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
        
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
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
