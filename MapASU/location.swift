//
//  location.swift
//  
//
//  Created by ibradle1 on 11/2/19.
//  Copyright © 2019 ibradle1. All rights reserved.
//

import Foundation

class location {
    var lat: Double?
    var lng: Double?
    var name: String?
    var adjacentPath: String?
    var abb: String?
    
    init(latitude:Double, longitude:Double, locname:String, adjPath:String, abbreviation:String){
        lat = latitude
        lng = longitude
        name = locname
        adjacentPath = adjPath
        abb = abbreviation
    }
}


