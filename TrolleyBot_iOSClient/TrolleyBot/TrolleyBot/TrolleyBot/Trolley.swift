//
//  Trolley.swift
//  TrolleyBot
//
//  Created by Adithya Narjala on 4/11/18.
//  Copyright © 2018 Monash. All rights reserved.
//

import UIKit
//Class to map with Firebase Trolley Data and Map Annotation
class Trolley: NSObject {
    var name: String?
    var lat: Double?
    var long: Double?
    var alarm: Bool?
    init(newname:String, newlat:Double, newlong:Double, newalarm:Bool ) {
        self.name = newname
        self.lat = newlat
        self.long = newlong
        self.alarm = newalarm
    }
    init(newname:String) {
        self.name = newname
        self.lat = 0
        self.long = 0
        self.alarm = false
        
    }
}
