//
//  Baggage.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/17/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

class Baggage: NSObject, NSCoding {
    // MARK: Properties
    var id: String?
    var name: String
    var origin: Airport
    var destination: Airport
    var status: String?
    var flight: String
    var imagePath: String?
    
    init(name: String, origin: Airport, destination: Airport, flight: String) {
        self.name = name
        self.origin = origin
        self.destination = destination
        self.flight = flight
        super.init()
    }
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("baggages")
    
    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(id, forKey: "id")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(origin.code, forKey: "from")
        aCoder.encodeObject(destination.code, forKey: "to")
        aCoder.encodeObject(flight, forKey: "flight")
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(imagePath, forKey: "image")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let id = aDecoder.decodeObjectForKey("id") as? String
        let from = aDecoder.decodeObjectForKey("from") as! String
        let to = aDecoder.decodeObjectForKey("to") as! String
        let flight = aDecoder.decodeObjectForKey("flight") as! String
        let status = aDecoder.decodeObjectForKey("status") as? String
        let path = aDecoder.decodeObjectForKey("image") as? String
        let departure = Airport(code: from)
        let destination = Airport(code: to)
        self.init(name: name, origin: departure, destination: destination, flight: flight)
        self.id = id
        self.status = status
        self.imagePath = path
    }
}
