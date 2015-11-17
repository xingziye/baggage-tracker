//
//  Baggage.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/17/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

struct Baggage {
    // MARK: Properties
    var name: String
    var departure: Airport
    var destination: Airport
    var currentStatus: String?
    var flight: String?
    var description: String {
        return "{\(name), }"
    }
    
    // MARK: Types
    
    struct PropertyKey {
        static let nameKey = "name"
        static let flightKey = "flight"
    }
    
    init(name: String, departure: Airport, destination: Airport) {
        self.name = name
        self.departure = departure
        self.destination = destination
    }
}
