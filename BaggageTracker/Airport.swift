//
//  Airport.swift
//  BaggageTracker
//
//  Created by Ziye Xing on 10/17/15.
//  Copyright © 2015 MSU ECE 480 Group 1. All rights reserved.
//

import UIKit

struct Airport {
    let code: String
    let name: String?
    let location: String?
    
    init(code: String) {
        self.code = code
        self.name = nil
        self.location = nil
    }
}
