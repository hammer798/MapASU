//
//  paths.swift
//  
//
//  Created by ibradle1 on 11/19/19.
//  Copyright © 2019 ibradle1. All rights reserved.
//

import Foundation

class paths{
    var allPaths: [path] = [path]()
    
    var names: [String] = ["Rural Road", "Gammage Parkway", "Apache Boulevard", "Mill Avenue", "University Drive", "McAlister Avenue", "Lemon Mall", "Orange Mall", "Forest Mall", "Tyler Mall", "McAlister Mall", "Palm Walk", "Cady Mall"]
    
    var coordinates: [((Double, Double),(Double, Double))] = [((33.411968,-111.926318),(33.421444,-111.926318)),((33.418037,-111.939537),(33.418037,-111.9366288)),((33.414759,-111.939537),(33.414759,-111.925247)), ((33.423401,-111.939979),(33.413101,-111.939979)), ((33.421957,-111.939537),(33.421957,-111.925247)), ((33.421957,-111.92952),(33.413101,-111.92952)), ((33.41595005, -111.9323051),(33.41595005, -111.9271553)), ((33.41835899, -111.9366449),(33.41833212, -111.9340217)), ((33.42120665, -111.9366288),(33.4176784, -111.9366288)), ((33.42027983, -111.936602),(33.42032572, -111.9289362)), ((33.41843063, -111.9301566),(33.41886495, -111.9301566)), ((33.42166334, -111.9327343),(33.41606423, -111.9326591)), ((33.42190512, -111.9350839),(33.41845749, -111.9350624))]
    
    var intersections: [[(String, Double)]] = [[("Apache Boulevard", 33.414759), ("University Drive", 33.421957)], [("Forest Mall", -111.9366288), ("Cady Mall", -111.9350624), ("Mill Avenue", -111.939979)], [("Rural Road", -111.926318), ("Mill Avenue", -111.939979), ("Forest Mall", -111.9366288), ("Cady Mall", -111.9350624), ("McAlister Avenue", -111.92952)], [("Apache Boulevard", 33.414759), ("Gammage Parkway", 33.418037), ("University Drive", 33.421957)], [("Mill Avenue", -111.939979), ("Rural Road", -111.926318), ("Palm Walk", -111.9326591), ("Cady Mall", -111.9350624), ("Forest Mall", -111.9366288), ("McAlister Mall", -111.9301566), ("McAlister Avenue", -111.92952)], [("University Drive", 33.421957), ("Apache Boulevard", 33.414759), ("Orange Mall", 33.41835899), ("Lemon Mall", 33.41595005), ("Tyler Mall", 33.42027983)], [("McAlister Avenue", -111.92952), ("Palm Walk", -111.9326591)], [("Orange Mall", 33.41835899)], [("University Drive", 33.421957), ("Gammage Parkway", 33.418037), ("Lemon Mall", 33.41595005), ("Tyler Mall", 33.42027983), ("Orange Mall", 33.41835899), ("Apache Boulevard", 33.414759)], [("Forest Mall", -111.9366288), ("Cady Mall", -111.9350624), ("Palm Walk", -111.9326591), ("McAlister Mall", -111.9301566), ("McAlister Avenue", -111.92952)], [("Tyler Mall", 33.42027983), ("Orange Mall", 33.41835899), ("University Drive", 33.421957)], [("University Drive", 33.421957), ("Tyler Mall", 33.42027983), ("Orange Mall", 33.41835899), ("Lemon Mall", 33.41595005)], [("Lemon Mall", 33.41505005), ("Orange Mall", 33.41835899), ("Tyler Mall", 33.42027983), ("University Drive", 33.421957), ("Apache Boulevard", 33.414759)]]
    
    var walkOnlys: [Bool] = [false, false, false, false, false, false, false, false, false, true, false, true, true]

    init(){
        for i in 0..<names.count {
            let pat:path = path(name:names[i], lat1:coordinates[i].0.0, long1:coordinates[i].0.1, lat2:coordinates[i].1.0, long2:coordinates[i].1.1, inter:intersections[i], walk:walkOnlys[i])
            allPaths.append(pat)
        }
    }
    
    func getPathObject(item: Int) -> path {
        return allPaths[item]
    }
    
    func getPathIndex(name:String)->Int{
        for i in 0...allPaths.count - 1{
            if allPaths[i].name == name {
                return i
            }
        }
        return -1
    }
    
    func getPathByName(name:String) -> path{
        for i in 0...allPaths.count - 1{
            if allPaths[i].name == name{
                return allPaths[i]
            }
        }
        return allPaths[0]
    }
    
    func getCount() -> Int {
        return names.count
    }
    
    
}
