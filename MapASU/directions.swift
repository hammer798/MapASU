//
//  directions.swift
//  finalproject
//
//  Created by ibradle1 on 11/23/19.
//  Copyright © 2019 ibradle1. All rights reserved.
//

import Foundation
import CoreLocation

class directions{
    var allPaths = paths()
    var allLocations = locations()
    var route:[direction] = [direction]()
    var start: location?
    var dest: location?
    
    init(s:location, d:location){
        start = s
        
        dest = d
    }
    
    func getRoute() -> Int{
        if(start?.adjacentPath == ""){
            start?.adjacentPath = getNearestPath()
        }
        
        if(start?.adjacentPath == "Fail"){
            var failDir = direction(p: "", dis: -1, dir: -1, m: "Fail")
            route.append(failDir)
            return 1
        }
        var startPathIndex = allPaths.getPathIndex(name: (start?.adjacentPath)!)
        var startPath = allPaths.getPathObject(item: startPathIndex)
        var currentIntersection: (String, Double)?
        
        var currentPath = startPath
        while currentPath.name != dest?.adjacentPath {
            var closestIndex:Int = 0
            var smallestDiff:Double = 10
            for i in 0..<currentPath.intersections.count{
                if(currentPath.orientation == 0){
                    if abs(currentPath.intersections[i].1 - dest!.lat!) < smallestDiff{
                        closestIndex = i
                        smallestDiff = abs(currentPath.intersections[i].1 - dest!.lat!)
                    }
                }
                else{
                    if abs(currentPath.intersections[i].1 - dest!.lng!) < smallestDiff{
                        closestIndex = i
                        smallestDiff = abs(currentPath.intersections[i].1 - dest!.lng!)
                    }
                }
            }
            currentIntersection = currentPath.intersections[closestIndex]
            
            if route.count == 0{
                var firstDirec: Int?
                if(startPath.orientation == 0){
                    if currentIntersection!.1 > start!.lat!{
                        firstDirec = 0
                    }
                    else{
                        firstDirec = 2
                    }
                }
                else{
                    if currentIntersection!.1 > start!.lng!{
                        firstDirec = 1
                    }
                    else{
                        firstDirec = 3
                    }
                }
                var firstDir = direction(p: startPath.name!, dis: 1, dir: firstDirec!, m: "First")
                route.append(firstDir)
            }

            //after choosing intersection
            var nextDirection: Int?
            if currentPath.orientation == 0 {
                if dest!.lng! > currentPath.long1!{
                    nextDirection = 1
                }
                else{
                    nextDirection = 3
                }
            }
            else{
                if dest!.lat! > currentPath.lat1!{
                    nextDirection = 0
                }
                else{
                    nextDirection = 2
                }
            }
            
            var nextPathIndex = allPaths.getPathIndex(name: currentIntersection!.0)
            var nextPath = allPaths.getPathObject(item: nextPathIndex)
            currentPath = nextPath

            var nextdir = direction(p: currentPath.name!, dis: -1, dir: nextDirection!, m: "")
            route.append(nextdir)
            
            
        }
        
        var finalDir = direction(p: dest!.adjacentPath!, dis: calcDistance(inter: currentIntersection!,d: dest!), dir: chooseDirection(inter: currentIntersection!, d: dest!), m: "Final")
        route.append(finalDir)
        
        
        return route.count
    }
    
    func calcDistance(inter:(String, Double),d:location) -> Int{
        var des:CLLocation = CLLocation(latitude: d.lat!, longitude: d.lng!)
        var st:CLLocation?
        if abs(d.lng! - inter.1) > abs(d.lat! - inter.1){
            st = CLLocation(latitude: d.lat!, longitude:inter.1)
        }
        else{
            st = CLLocation(latitude: inter.1, longitude:d.lng!)
        }
        var meters:Double = st!.distance(from: des)
        var feet:Int = Int(round(meters*3.28084))
        
        return feet
    }
    
    func getNearestPath() -> String{
        var smallest:Double = 1
        var smallestIndex = -1
        for i in 1..<allLocations.allLocations.count{
            if calcPointDistance(l:allLocations.allLocations[i]) < smallest{
                smallest = calcPointDistance(l:allLocations.allLocations[i])
                smallestIndex = i
            }
        }
        if smallest < 1{
            return allLocations.allLocations[smallestIndex].adjacentPath!
        }
        return "Fail"
    }
    
    func calcPointDistance(l:location) ->Double{
        var lng = (start!.lng! - l.lng!) * (start!.lng! - l.lng!)
        var lat = (start!.lat! - l.lat!) * (start!.lat! - l.lat!)
        return sqrt(lat+lng)
    }
    
    func chooseDirection(inter: (String, Double), d:location) -> Int{
        if abs(inter.1 - d.lat!) > abs(inter.1 - d.lng!){
            if inter.1 > d.lng!{
                return 1
            }
            else{
                return 3
            }
        }
        else{
            if inter.1 > d.lat!{
                return 2
            }
            else{
                return 0
            }
        }
    }
    
}
