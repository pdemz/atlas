//
//  MapsHelper.swift
//  Yokwe2
//
//  Created by Pierce Demarreau on 1/17/16.
//  Copyright © 2016 Pierce Demarreau. All rights reserved.
//

import Foundation
import GoogleMaps

class MapsHelper{
    
    var start:String?
    var end:String?
    var distance:String?
    var duration:String?
    var rstart:String?
    var rend:String?
    
    func makeDirectionsRequest(completion:(result:String)->Void){
        
        var url:String
        
        if rstart != nil{
           url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start!)&destination=\(end!)&waypoints=via:\(rstart!)%7Cvia:\(rend!)&key=AIzaSyCqZ50c_NV-tYwVOMwxaS4XY-vomaxsOEc"
        }else{
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start!)&destination=\(end!)&key=AIzaSyCqZ50c_NV-tYwVOMwxaS4XY-vomaxsOEc"
        }
        
        print(url)
        let request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                return
            } else {
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))

                    let jsonResults = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                    let routes = jsonResults.objectForKey("routes") as! [NSDictionary]
                    if routes.count > 0{
                        
                        let legs = routes[0].objectForKey("legs") as! [NSDictionary]
                        self.distance = legs[0].objectForKey("distance")?.valueForKey("text") as? String
                        self.duration = legs[0].objectForKey("duration")?.valueForKey("text") as? String
                        let overviewPolyline = routes[0].objectForKey("overview_polyline")?.valueForKey("points") as! String
                        
                        print("distance, duration: \(self.distance!),\(self.duration!)")
                        completion(result: overviewPolyline)
                    }
                    
                } catch {
                    // failure
                    print("Fetch failed: \((error as NSError).localizedDescription)")
                }
                
            }
        }
        task.resume()
    }
    
    
}

