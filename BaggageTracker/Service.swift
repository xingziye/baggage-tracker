//
//  Service.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/27/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import Foundation

class Service {
    var settings: String
    
    init() {
        self.settings = "http://ec2-54-148-117-15.us-west-2.compute.amazonaws.com/serviceAPI.php"
    }
    
    func getInfo(queries: String, callback: (NSArray) -> ()) {
        requestTask(settings, queries: queries, callback: callback)
    }
    
    func requestTask(url: String, queries: String, callback: (NSArray) -> ()) {
        //let nsURL = NSURL(string: url)
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = queries.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            do {
                let response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                callback(response)
                print(response)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}