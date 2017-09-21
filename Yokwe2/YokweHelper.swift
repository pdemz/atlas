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
import Alamofire
class YokweHelper{
    
    static let serverAddress = "http://localhost:8080/yokwe/"
    //static let serverAddress = "https://www.atlascarpool.com/"

    //get all trips from server
    class func getTrips(completion: @escaping (_ result:[TripStatusObject])->Void){
        var urlString = "\(serverAddress)/atlas?type=getTrips"
        urlString = addCredentials(urlString)

        Alamofire.request(urlString).responseJSON { response in
            if let json = response.result.value {
                
                //convert JSON into a list
                let tripList = json as! [NSDictionary]
                var tsoList = [TripStatusObject]()
                
                //Prepare to loop with asynchronous calls
                let group = DispatchGroup()
                
                //convert each element of the list into a trip status object
                //Requires calls to FB, requires sorting out which info you need
                for trip in tripList{
                    group.enter()
                    
                    //Create status sentence using FB request and mode
                    let mode = trip.value(forKey: "mode") as! String
                    let status = trip.value(forKey: "status") as! String
                    var tsoStatus:String
                    
                    //If its a pending response, get the name from FB
                    if status == "pendingResponse" {
                        //Get user name
                        var user = Driver.init(name: nil, photo: nil, mutualFriends: nil, fareEstimate: nil, eta: nil, userID: trip.value(forKey: "userID") as! String, accessToken: trip.value(forKey: "accessToken") as! String, addedTime: nil)
                        
                        FacebookHelper.driverGraphRequest(user, completion: {(result) -> Void in
                            let name = result.name!
                            var tsoStatus = "Waiting for \(name) to respond"
                            
                            let tso = TripStatusObject(newTo: trip.value(forKey: "destinationName") as! String, newFrom: trip.value(forKey:"originName") as! String, newStatus: tsoStatus, newMode: mode)
                            tso.tripID = trip.value(forKey: "tripID") as! Int
                            
                            tsoList.append(tso)
                            group.leave()
                        })
                        
                    //Otherwise, its simple.
                    }else{
                        switch status{
                        case "rideRequest":
                            tsoStatus = "Ride request is in the queue"
                        case "driveRequest":
                            tsoStatus = "Driver offer is in the queue"
                        default:
                            tsoStatus = "Waiting for the driver to start the trip"
                        }
                        
                        let tso = TripStatusObject(newTo: trip.value(forKey: "destinationName") as! String, newFrom: trip.value(forKey:"originName") as! String, newStatus: tsoStatus, newMode: mode)
                        tso.tripID = trip.value(forKey: "tripID") as! Int
                        
                        tsoList.append(tso)
                        group.leave()
                        
                    }
                    
                }
                
                //Once all elements are processed, return the list.
                group.notify(queue: .main) {
                    completion(tsoList)
                }
            }
        }
    }
    
    //delete trip from database
    class func deleteTrip(tripID:Int){
        var urlString = "\(serverAddress)/atlas?type=deleteTrip&tripID=\(tripID)"
        urlString = addCredentials(urlString)
        
        Alamofire.request(urlString)
        
    }
    
    //get credit card info for the user
    class func getCardInfo(_ completion:@escaping (_ result:String?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)
        
        //Add parameters
        let type = "getCardInfo"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        //Send HTTP post request
        URLSession.shared.dataTask(with: request){
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(nil)
            }
            
            if let responseString = String(data: data!, encoding: String.Encoding.utf8){
                if responseString != "null"{
                    completion(responseString)
                    
                }else{
                    completion(nil)

                }
            }
            completion(nil)

        }.resume()
    }
    
    class func getActiveTrips(_ completion:@escaping (_ result:[TripStatusObject])->Void){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)
        
        //Add parameters
        let type = "getTripsAndRequests"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        var tripStatusObjects = [TripStatusObject]()
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            
            if responseString != nil && responseString != ""{
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary{
                     
                        let trips = json.object(forKey: "trips") as! [NSDictionary]
                        
                        //Store all the trips in a list
                        for trip in trips{
                            let tt = TripStatusObject(newTo: trip.value(forKey: "to") as! String, newFrom: trip.value(forKey: "from") as! String, newStatus: trip.value(forKey: "status") as! String, newMode: trip.value(forKey: "mode") as! String)
                
                            tripStatusObjects.append(tt)
                        }
                        
                        completion(tripStatusObjects)
                    }
                    
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
            }
            
            completion(tripStatusObjects)
            
        })
        
        task.resume()
    }
    
    class func getBankInfo(_ completion:@escaping (_ result:String?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)
        
        //Add parameters
        let type = "getBankInfo"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(nil)
            }
            
            if let responseString = String(data: data!, encoding: String.Encoding.utf8){
                if responseString != "null"{
                    completion(responseString)
                    
                }else{
                    completion(nil)
                    
                }
            }
            completion(nil)
            
        })
        task.resume()
    }
    
    class func deleteBank(){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "deleteBank"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
        })
        task.resume()
    }
    
    class func deleteCard(){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "deleteCustomer"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
        })
        task.resume()
    }
    
    class func submitReview(_ stars: Int, review: String, revieweeID:String, reviewType:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "review"
        
        request.httpMethod = "POST"
        
        var postString = "type=\(type)&stars=\(stars)&review=\(review)&revieweeID=\(revieweeID)&reviewType=\(reviewType)"
        
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        })
        task.resume()
    }
    
    //Authenticates a user with email and password combo
    class func authenticateEmail(_ completion:@escaping (_ result:Bool)->Void){
        //Main part of address
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "authenticateEmail"
        let email = SharingCenter.sharedInstance.email
        let password = SharingCenter.sharedInstance.password
        
        let postString = "type=\(type)&email=\(email!)&password=\(password!)"
        
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(false)
            }
            
            //userID;accessToken_
            if let responseString = String(data: data!, encoding: String.Encoding.utf8){
                
                //User logged in successfully!
                if(responseString == "success"){
                    completion(true)

                }else{
                    completion(false)

                }
                
            }
            
        })
        
        task.resume()
    }
    
    //Returns a list of drivers given a rider
    class func getDriverList(_ completion:@escaping (_ result:[Driver])->Void){
        
        //Main part of address
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "rideRequest"
        let start = SharingCenter.sharedInstance.start.replacingOccurrences(of: " ", with: "+")
        let dest = SharingCenter.sharedInstance.destination.replacingOccurrences(of: " ", with: "+")
        
        var postString = "origin=\(start)&destination=\(dest)&type=\(type)"
        
        postString = addCredentials(postString)
        
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            //userID;accessToken_
            if let responseString = String(data: data!, encoding: String.Encoding.utf8){
                var driverStringList = responseString.components(separatedBy: "_")

                //Get the tripID (first element) from the list then remove it.
                let tripID = driverStringList.first
                SharingCenter.sharedInstance.latestTripID = tripID
                driverStringList.remove(at: 0)
                
                var driverList:[Driver] = [Driver]()
                for driver in driverStringList{
                    if driver != "" && responseString != "null\n"{
                        var newb = driver.components(separatedBy: ";")
                        let newDriver = Driver(name: nil, photo: nil, mutualFriends: newb[3], fareEstimate: nil, eta: nil, userID: newb[0], accessToken: newb[1], addedTime: Double(newb[2]))
                        newDriver.price = newb[4]
                        newDriver.aboutMe = newb[5]
                        newDriver.name = newb[6]
                        newDriver.tripID = newb[7]
                        print("new driver tripid")
                        print(newDriver.tripID)
                        driverList.append(newDriver)
                    }
                }
                completion(driverList)

            }
            
        })
        
        task.resume()
    }
    
    //returns a list of riders given a driver
    class func getRiderList(_ completion:@escaping (_ result:[Rider])->Void){
        
        //Main part of address
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "driveRequest"
        let start = SharingCenter.sharedInstance.start.replacingOccurrences(of: " ", with: "+")
        let dest = SharingCenter.sharedInstance.destination.replacingOccurrences(of: " ", with: "+")
        
        request.httpMethod = "POST"
        
        var postString = "origin=\(start)&destination=\(dest)&type=\(type)&limit=30"
        
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            //id;accessToken;origin;destination;addedTime_
            if let responseString = String(data: data!, encoding: String.Encoding.utf8){
                
                var riderStringList = responseString.components(separatedBy: "_")
                
                //Get the tripID (first element) from the list then remove it.
                let tripID = riderStringList.first
                riderStringList.remove(at: 0)
                SharingCenter.sharedInstance.latestTripID = tripID!
                
                var riderList:[Rider] = [Rider]()
                
                for rider in riderStringList{
                    if rider != "" && rider.contains(";"){
                        var newb = rider.components(separatedBy: ";")
                        let newRider = Rider(name: nil, origin: newb[2], destination: newb[3], photo: nil, mutualFriends: newb[5], fareEstimate: nil, addedTime: newb[4], userID: newb[0], accessToken: newb[1])
                        newRider.price = newb[6]
                        newRider.aboutMe = newb[7]
                        newRider.name = newb[8]
                        newRider.tripID = newb[9]
                        
                        riderList.append(newRider)
                        
                    }
                }
                    
                completion(riderList)
                
            }
        
        })
        
        task.resume()
    }
    
    //Checks if user has received any drive/ride requests
     //If not nil, will return type;userID;accessToken;origin;destination;driver.available;addedTime
    class func update(_ completion:@escaping (_ result:[String]?)->Void){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "update"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(nil)
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            if responseString != "nothing"{
                let resultsArray = responseString.components(separatedBy: ";")
                completion(resultsArray)
            }
            else{
                completion(nil)
            }
            
            
        })
        task.resume()
    }
    
    //Checks if user has received any drive/ride requests
    //If not nil, will return type;userID;accessToken;origin;destination;driver.available;addedTime
    class func getUser(_ completion:@escaping (_ result:User?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "getUser"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(nil)
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)
            
            
            if responseString != nil && responseString != ""{

                do {
                    if let jsonResults = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary{
                        let uu = User(json: jsonResults)
                        completion(uu)
                    }
                    
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                    completion(nil)
                }
            }
            else{
                completion(nil)
            }
            
            
        })
        task.resume()
    }
    
    //Store payment info
    class func updatePaymentInfo(_ token:String, email:String){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)
        
        //Add parameters
        let type = "updatePaymentInfo"
        
        request.httpMethod = "POST"
        
        var postString = "type=\(type)&token=\(token)"
        if FBSDKAccessToken.current() != nil{
            postString += "&email=\(email)"
        }
        
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            print("token: \(token)")
            print("Payment info stored.")
            
        })
        task.resume()
    }
    
    //Create stripe account
    class func createStripeAccount(_ firstName:String, lastName:String, day:String, month:String,year:String, completion:@escaping (_ result:String?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "createStripeAccount"
        
        var postString = "type=\(type)&firstName=\(firstName)&lastName=\(lastName)" +
        "&day=\(day)&month=\(month)&year=\(year)"
        postString = addCredentials(postString)
        
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            if let response = String(data: data!, encoding: String.Encoding.utf8){
                completion(response)
            }
            
            completion(nil)
            
        })
        task.resume()
    }
    
    class func addBankAccount(_ name:String, email:String?, accountNum:String, routingNum:String, completion:@escaping (_ result:String?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "addBankAccount"
        
        var postString = "type=\(type)&name=\(name)&accountNum=\(accountNum)&routingNum=\(routingNum)"
        postString = addCredentials(postString)

        //Email is optional - check if it is null
        if let emailString = email{
            postString += "&email=\(emailString)"
        }
        
        request.httpMethod = "POST"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            if let response = String(data: data!, encoding: String.Encoding.utf8){
                if response != "null"{
                    completion(response)
                }
            }
            
            completion(nil)
            
        })
        task.resume()
    }
    
    //Store/update user
    //Verbose, but simple - and probably the least amount of code for the job
    class func storeUser(){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        var postString = "type=storeUser"
        
        if FBSDKAccessToken.current() != nil{
            if let userID = SharingCenter.sharedInstance.userID{
                postString += "&userID=\(userID)"
            }
            if let accessToken = FBSDKAccessToken.current().tokenString{
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
                
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        })
        task.resume()
    }
    
    //Store/update user
    class func storeUser(_ user:User){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        var postString = "type=storeUser"
        if let userID = SharingCenter.sharedInstance.userID{
            postString += "&userID=\(userID)"
        }
        if let accessToken = FBSDKAccessToken.current().tokenString{
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

        
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        })
        task.resume()
    }

    //Store/update user
    //Verbose, but simple - and probably the least amount of code for the job
    class func storeUserWithCompletion(_ completion:@escaping ()->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)
        
        print("Well, we tried to store the user")
        
        //Add parameters
        var postString = "type=storeUser"
        
        if FBSDKAccessToken.current() != nil{
            if let userID = SharingCenter.sharedInstance.userID{
                postString += "&userID=\(userID)"
            }
            if let accessToken = FBSDKAccessToken.current().tokenString{
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
        
        request.httpMethod = "POST"
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            completion()
            
        })
        task.resume()
    }

    
    //Store aboutMe in DB
    class func storeAboutMe(_ aboutMe:String){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "updateProfile"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&aboutMe=\(aboutMe)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        })
        task.resume()
    }
    
    //Get about me from db
    class func getProfile(_ completion:@escaping (_ result: String?)->Void){
        //Gets about me and phone number -- for when the user views their own profile
        
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "getProfile"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            if responseString != "null"{
                print("profile:")
                print(responseString)
                completion(responseString)
            }
            else{
                completion(nil)
            }
            
            
        })
        task.resume()
    }
    
    class func doesUserExist(_ completion:@escaping (_ result: Bool)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "doesUserExist"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            if responseString == "true"{
                completion(true)
                
            }else{
                completion(false)
                
            }
            
        })
        task.resume()
        
    }
    
    //Store phone number
    class func storePhone(_ phone:String){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "updatePhone"
        
                
        request.httpMethod = "POST"
        var postString = "type=\(type)&phone=\(phone)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
        })
        task.resume()
    }
    
    //Get phone number from db
    class func getPhone(_ completion:@escaping (_ result: String?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "getPhone"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            if responseString != "NULL"{
                completion(responseString)
            }
            else{
                completion(nil)
            }
            
            
        })
        task.resume()
    }
    
    //Called after a rider is selected by a driver
    class func riderSelection(_ riderID:String, addedTime:String, price:String, riderTripID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "riderSelection"
        
        request.httpMethod = "POST"
        
        var postString = "type=\(type)&riderID=\(riderID)&addedTime=\(addedTime)&price=\(price)&tripID=\(SharingCenter.sharedInstance.latestTripID!)&requesteeTripID=\(riderTripID)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called after a driver is selected by a rider
    class func driverSelection(_ driverID:String, addedTime:String, price:String, driverTripID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "driverSelection"
        
        request.httpMethod = "POST"
        
        //add duration, distance, all this other crap that you don't have. Recalculate it on the server side.
        var postString = "type=\(type)&driverID=\(driverID)&addedTime=\(addedTime)&price=\(price)&tripID=\(SharingCenter.sharedInstance.latestTripID!)&requesteeTripID=\(driverTripID)"
        
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called when a request is accepted
    class func acceptRequest(_ requesterID:String, requestType:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "accept"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&requesterID=\(requesterID)&requestType=\(requestType)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called when driver rejects a request from a rider
    class func rideReject(_ requesterID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "rideReject"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&requesterID=\(requesterID)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called when rider rejects a request from a driver
    class func driveReject(_ requesterID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "driveReject"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&requesterID=\(requesterID)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called when user cancels an active trip - no charge is made
    class func cancelTrip(_ riderID:String, driverID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "cancel"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)&driverID=\(driverID)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called when driver arrives at rider origin
    class func pickUp(_ riderID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "pickUp"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        
        task.resume()
    }
    
    //Called when driver starts the trip
    class func startTrip(_ riderID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "start"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Called when user ends an active trip $$
    class func endTrip(_ riderID:String, driverID:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "end"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&riderID=\(riderID)&driverID=\(driverID)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                return
            }
        })
        task.resume()
    }
    
    //Fetches trips, pending responses, or any requests
    class func getUpdate(_ completion:@escaping (_ result: NSDictionary?)->Void){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "update"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)
    
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            if error != nil {
                print("error\(error)")
                completion(nil)
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            print("update: \(responseString)")
            
            print("the response: \(response)")
            
            do {
                if let jsonResults = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary{
                    print("json: \(jsonResults)")
                    completion(jsonResults)
                }else{
                    completion(nil)
                }
                
            } catch {
                // failure
                print("Fetch failed: \((error as NSError).localizedDescription)")
                completion(nil)
            }
            
        })
        task.resume()
    }
    
    //Get phone number from db with user ID and accessToken
    class func getPhoneWithID(_ userID:String, accessToken:String, completion:@escaping (_ result: String?)->Void){
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "getPhone"
        request.httpMethod = "POST"
        
        var postString = "type=\(type)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            if responseString != "NULL"{
                completion(responseString)
            }
            else{
                completion(nil)
            }
            
            
        })
        task.resume()
    }
    
    //Get about me from db with ID and accessToken
    class func getProfileWithID(_ userID:String, accessToken:String, completion:@escaping (_ result: String?)->Void){
        //Gets about me and phone number -- for when the user views their profile
        
        let addr = URL(string: "\(serverAddress)/profile")
        var request = URLRequest(url: addr!)
        
        //Add parameters
        let type = "getProfile"
        request.httpMethod = "POST"
        var postString = "type=\(type)"
        postString = addCredentials(postString)

        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                return
            }
            
            let responseString = String(data: data!, encoding: String.Encoding.utf8)!
            if responseString != "null"{
                print("profile:")
                print(responseString)
                completion(responseString)
            }
            else{
                completion(nil)
            }
            
            
        })
        task.resume()
    }
    
    //Verify code for sms
    class func verifyCode(_ code:String, number:String, completion:@escaping (_ result: Bool)->Void){
        
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)

        //Add parameters
        let type = "sms"
        let action = "verify"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&action=\(action)&code=\(code)&number=\(number)"
        postString = addCredentials(postString)
        
        print("Verify code post string: \(postString)")
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
                completion(false)
            }
            
            do {
                if let jsonResults = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary{
                    print("json result: \(jsonResults)")
                    let valid = jsonResults.value(forKey: "verified") as! Bool
                    completion(valid)
                    
                }else{
                    completion(false)
                }
                
            } catch {
                // failure
                print("Code verification failed: \((error as NSError).localizedDescription)")
                completion(false)
            }

            
            
        })
        task.resume()
    }
    
    class func requestVerificationCode(_ number:String){
        let addr = URL(string: "\(serverAddress)/atlas")
        var request = URLRequest(url: addr!)
()
        //Add parameters
        let type = "sms"
        let action = "send"
        
        request.httpMethod = "POST"
        var postString = "type=\(type)&action=\(action)&number=\(number)"
        postString = addCredentials(postString)
        
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        //Send HTTP post request
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            data, response, error in
            
            if error != nil {
                print("error\(error)")
            }
            
        })
        task.resume()

        
    }
    
    class func addCredentials(_ postString:String) -> String{
        var newString = postString
        
        //Attach proper credentials
        if FBSDKAccessToken.current() == nil{
            if let email = SharingCenter.sharedInstance.email{
                newString += "&email=\(email)"
            }
            if let password = SharingCenter.sharedInstance.password{
                newString += "&password=\(password)"
            }
            
        }else{
            if let userID = FBSDKAccessToken.current().userID{
                newString += "&userID=\(userID)"
            }
            if let accessToken = FBSDKAccessToken.current().tokenString{
                newString += "&accessToken=\(accessToken)"
            }
        }
        
        return newString
    }

    
}
