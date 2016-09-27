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
    
    class func getCardInfo(completion:(result:String?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getCardInfo"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: nil)
            }
            
            if let responseString = String(data: data!, encoding: NSUTF8StringEncoding){
                if responseString != "null"{
                    completion(result: responseString)
                    
                }else{
                    completion(result: nil)

                }
            }
            completion(result: nil)

        }
        task.resume()
    }
    
    class func getBankInfo(completion:(result:String?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "getBankInfo"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        print("Here is the post string: \(postString)")
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: nil)
            }
            
            if let responseString = String(data: data!, encoding: NSUTF8StringEncoding){
                if responseString != "null"{
                    completion(result: responseString)
                    
                }else{
                    completion(result: nil)
                    
                }
            }
            completion(result: nil)
            
        }
        task.resume()
    }
    
    class func deleteBank(){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "deleteBank"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
        }
        task.resume()
    }
    
    class func deleteCard(){
        let addr = NSURL(string: "https://www.yokweapp.com/profile")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "deleteCustomer"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
        }
        task.resume()
    }
    
    class func submitReview(stars: Int, review: String, revieweeID:String, reviewType:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "review"
        
        request.HTTPMethod = "POST"
        
        var postString = "type=\(type)&stars=\(stars)&review=\(review)&revieweeID=\(revieweeID)&reviewType=\(reviewType)"
        
        postString = addCredentials(postString)
        
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
    
    //Authenticates a user with email and password combo
    class func authenticateEmail(completion:(result:Bool)->Void){
        //Main part of address
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "authenticateEmail"
        let email = SharingCenter.sharedInstance.email
        let password = SharingCenter.sharedInstance.password
        
        let postString = "type=\(type)&email=\(email!)&password=\(password!)"
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: false)
            }
            
            //userID;accessToken_
            if let responseString = String(data: data!, encoding: NSUTF8StringEncoding){
                print("response string: \(responseString)")
                
                //User logged in successfully!
                if(responseString == "success"){
                    completion(result: true)

                }else{
                    completion(result: false)

                }
                
            }
            
        }
        
        task.resume()
    }
    
    //Returns a list of drivers given a rider
    class func getDriverList(completion:(result:[Driver])->Void){
        
        //Main part of address
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "rideRequest"
        let start = SharingCenter.sharedInstance.start.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let dest = SharingCenter.sharedInstance.destination.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        var postString = "origin=\(start)&destination=\(dest)&type=\(type)"
        
        postString = addCredentials(postString)
        
        request.HTTPMethod = "POST"
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
                        newDriver.aboutMe = newb[5]
                        newDriver.name = newb[6]
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
        
        request.HTTPMethod = "POST"
        var postString = "origin=\(start)&destination=\(dest)&type=\(type)&limit=30"
        
        postString = addCredentials(postString)
        
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
                        print(rider)
                        var newb = rider.componentsSeparatedByString(";")
                        let newRider = Rider(name: nil, origin: newb[2], destination: newb[3], photo: nil, mutualFriends: newb[5], fareEstimate: nil, addedTime: newb[4], userID: newb[0], accessToken: newb[1])
                        newRider.price = newb[6]
                        newRider.aboutMe = newb[7]
                        newRider.name = newb[8]
                        
                        print("newb5: \(newb[5])")
                        
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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        
        postString = addCredentials(postString)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: nil)
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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: nil)
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
            
            
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
        
        request.HTTPMethod = "POST"
        
        var postString = "type=\(type)&token=\(token)"
        if FBSDKAccessToken.currentAccessToken() != nil{
            postString += "&email=\(email)"
        }
        
        postString = addCredentials(postString)

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
        
        var postString = "type=\(type)&firstName=\(firstName)&lastName=\(lastName)" +
        "&day=\(day)&month=\(month)&year=\(year)&line1=\(line1)&city=\(city)&state=\(state)&zip=\(zip)&last4=\(last4)"
        postString = addCredentials(postString)
        
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
        
        var postString = "type=\(type)&name=\(name)&accountNum=\(accountNum)&routingNum=\(routingNum)"
        postString = addCredentials(postString)

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
        
        if FBSDKAccessToken.currentAccessToken() != nil{
            if let userID = SharingCenter.sharedInstance.userID{
                postString += "&userID=\(userID)"
            }
            if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString{
                postString += "&accessToken=\(accessToken)"
            }
        }else{
            if let name = SharingCenter.sharedInstance.name{
                postString += "&name=\(name)"
            }
            if let password = SharingCenter.sharedInstance.password{
                postString += "&password=\(password)"
            }
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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&aboutMe=\(aboutMe)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

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
        
                
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&phone=\(phone)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        
        var postString = "type=\(type)&riderID=\(riderID)&addedTime=\(addedTime)&price=\(price)"
        postString = addCredentials(postString)

        print("POST STRINGGGGG: \(postString)")
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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&driverID=\(driverID)&addedTime=\(addedTime)&price=\(price)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&requesterID=\(requesterID)&requestType=\(requestType)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&requesterID=\(requesterID)"
        postString = addCredentials(postString)

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
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&requesterID=\(requesterID)"
        postString = addCredentials(postString)

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
    
    //Called when user cancels an active trip - no charge is made
    class func cancelTrip(riderID:String, driverID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "cancel"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)&driverID=\(driverID)"
        postString = addCredentials(postString)
        
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
    
    //Called when driver arrives at rider origin
    class func pickUp(riderID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "pickUp"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)"
        postString = addCredentials(postString)
        
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
    
    //Called when driver starts the trip
    class func startTrip(riderID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "start"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)"
        postString = addCredentials(postString)
        
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
    
    //Called when user ends an active trip $$
    class func endTrip(riderID:String, driverID:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "end"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)&driverID=\(driverID)"
        postString = addCredentials(postString)

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
    class func getUpdate(completion:(result: NSDictionary?)->Void){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "update"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
    
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            if error != nil {
                print("error\(error)")
                completion(result: nil)
                return
            }
            
            let responseString = String(data: data!, encoding: NSUTF8StringEncoding)!
            print("update: \(responseString)")
            
            print("the response: \(response)")
            
            do {
                if let jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary{
                    print("json: \(jsonResults)")
                    completion(result: jsonResults)
                }else{
                    completion(result: nil)
                }
                
            } catch {
                // failure
                print("Fetch failed: \((error as NSError).localizedDescription)")
                completion(result: nil)
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
        
        var postString = "type=\(type)"
        postString = addCredentials(postString)

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
        var postString = "type=\(type)"
        postString = addCredentials(postString)

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
    
    //Verify code for sms
    class func verifyCode(code:String, number:String, completion:(result: Bool)->Void){
        
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "sms"
        let action = "verify"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&action=\(action)&code=\(code)&number=\(number)"
        postString = addCredentials(postString)
        
        print("Verify code post string: \(postString)")
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(result: false)
            }
            
            do {
                if let jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary{
                    print("json result: \(jsonResults)")
                    let valid = jsonResults.valueForKey("verified") as! Bool
                    completion(result: valid)
                    
                }else{
                    completion(result: false)
                }
                
            } catch {
                // failure
                print("Code verification failed: \((error as NSError).localizedDescription)")
                completion(result: false)
            }

            
            
        }
        task.resume()
    }
    
    class func requestVerificationCode(number:String){
        let addr = NSURL(string: "https://www.yokweapp.com/atlas")
        let request = NSMutableURLRequest(URL: addr!)
        
        //Add parameters
        let type = "sms"
        let action = "send"
        
        request.HTTPMethod = "POST"
        var postString = "type=\(type)&action=\(action)&number=\(number)"
        postString = addCredentials(postString)
        
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Send HTTP post request
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
        }
        task.resume()

        
    }
    
    class func addCredentials(postString:String) -> String{
        var newString = postString
        
        //Attach proper credentials
        if FBSDKAccessToken.currentAccessToken() == nil{
            if let email = SharingCenter.sharedInstance.email{
                newString += "&email=\(email)"
            }
            if let password = SharingCenter.sharedInstance.password{
                newString += "&password=\(password)"
            }
            
        }else{
            if let userID = FBSDKAccessToken.currentAccessToken().userID{
                newString += "&userID=\(userID)"
            }
            if let accessToken = FBSDKAccessToken.currentAccessToken().tokenString{
                newString += "&accessToken=\(accessToken)"
            }
        }
        
        return newString
    }

    
}
