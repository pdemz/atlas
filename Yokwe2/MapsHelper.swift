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
    
    func makeDirectionsRequest(_ completion:@escaping (_ result:String)->Void){
        
        var path:String
        
        if rstart != nil{
           path = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start!)&destination=\(end!)&waypoints=via:\(rstart!)%7Cvia:\(rend!)&key=AIzaSyCqZ50c_NV-tYwVOMwxaS4XY-vomaxsOEc"
        }else{
            path = "https://maps.googleapis.com/maps/api/directions/json?origin=\(start!)&destination=\(end!)&key=AIzaSyCqZ50c_NV-tYwVOMwxaS4XY-vomaxsOEc"
        }
        
        print(path)
        let url = URL(string: path)
        let session = URLSession.shared
        let task = session.dataTask(with:url!) { (data, response, error) -> Void in
            
            if error != nil {
                print("error=\(error!)")
                return
            } else {
                do {
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))

                    let jsonResults = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    let routes = jsonResults.object(forKey: "routes") as! [NSDictionary]
                    if routes.count > 0{
                        
                        let legs = routes[0].object(forKey: "legs") as! [NSDictionary]
                        self.distance = (legs[0].object(forKey: "distance") as AnyObject).value(forKey: "text") as? String
                        self.duration = (legs[0].object(forKey: "duration") as AnyObject).value(forKey: "text") as? String
                        let overviewPolyline = (routes[0].object(forKey: "overview_polyline") as AnyObject).value(forKey: "points") as! String
                        
                        print("distance, duration: \(self.distance!),\(self.duration!)")
                        completion(overviewPolyline)
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

