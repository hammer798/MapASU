//
//  path.swift
//  
//
//  Created by ibradle1 on 11/19/19.
//  Copyright © 2019 ibradle1. All rights reserved.
//

import Foundation

class path{
    var name: String?
    var lat1: Double?
    var long1: Double?
    var lat2: Double?
    var long2: Double?
    var walkOnly: Bool?
    var orientation:Int? //0 is N/S, 1 is W/E
    var intersections: [(String, Double)] = [(String, Double)]()
    
    init(name:String, lat1:Double, long1:Double, lat2:Double, long2:Double, inter:[(String, Double)], walk:Bool){
        self.name = name
        self.lat1 = lat1
        self.lat2 = lat2
        self.long1 = long1
        self.long2 = long2
        self.intersections = inter
        self.walkOnly = walk
        
        if abs(lat1 - lat2) > abs(long1 - long2) {
            self.orientation = 0
        }
        else{
            self.orientation = 1
        }
    }
    
    func getInterWith(name:String) -> (Double, Double){
        var intersection:(Double,Double) = (0,0)
        intersections.forEach{ inter in
            if inter.0 == name{
                if orientation == 0{
                    intersection = (inter.1, long1!)
                }
                else{
                    intersection = (lat1!, inter.1)
                }
            }
        }
        return intersection
    }
    
}
