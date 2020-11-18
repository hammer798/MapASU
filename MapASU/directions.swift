//
//  directions.swift
//  
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
    
    var possibleRoutes:[(Int,[direction])] = [(Int,[direction])]()
    
    init(s:location, d:location){
        start = s
        dest = d
    }
    
    func calcDistance(inter:(String, Double),d:(Double,Double)) -> Int{
        let des:CLLocation = CLLocation(latitude: d.0, longitude: d.1)
        var st:CLLocation?
        if abs(d.1 - inter.1) > abs(d.0 - inter.1){
            st = CLLocation(latitude: d.0, longitude:inter.1)
        }
        else{
            st = CLLocation(latitude: inter.1, longitude:d.1)
        }
        let meters:Double = st!.distance(from: des)
        let feet:Int = Int(round(meters*3.28084))
        
        return feet
    }
    
    func calcFinalDistance(p1:(Double,Double), p2:(Double,Double)) -> Int{
        let st = CLLocation(latitude:p1.0, longitude: p1.1)
        let des = CLLocation(latitude:p2.0, longitude:p2.1)
        let meters:Double = st.distance(from:des)
        let feet:Int = Int(round(meters*3.28084))
        
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
        let lng = (start!.lng! - l.lng!) * (start!.lng! - l.lng!)
        let lat = (start!.lat! - l.lat!) * (start!.lat! - l.lat!)
        return sqrt(lat+lng)
    }
    
    func chooseDirection(inter: (String, Double), d:(Double,Double)) -> Int{
        if abs(inter.1 - d.0) > abs(inter.1 - d.1){
            if inter.1 > d.1{
                return 1
            }
            else{
                return 3
            }
        }
        else{
            if inter.1 > d.0{
                return 2
            }
            else{
                return 0
            }
        }
    }
    
    func chooseFinalDirection(p1:(Double, Double), p2:(Double, Double), orient:Int) -> Int{
        if orient == 0{
            if p1.0 > p2.0{
                return 2
            }
            else{
                return 0
            }
        }
        else{
            if p1.1 > p2.1{
                return 3
            }
            else{
                return 1
            }
        }    }
    
    
    //find shortest route in the queue, remove it from the queue and return it for processing
    func nextInQueue() -> (Int, [direction]){
        var nearest = -1
        var nearestIndex = -1
        var shortestRoute:(Int,[direction]) = (0, [])
        
        if(possibleRoutes.count > 0){
            var currentIndex = 0
            possibleRoutes.forEach{ route in
                if nearest == -1 || route.0 < nearest{
                    nearest = route.0
                    nearestIndex = currentIndex
                    shortestRoute = route
                }
                currentIndex+=1
            }
            
            possibleRoutes.remove(at:nearestIndex)
        }
        
        return shortestRoute
    }
    
    func dijkstra(start:location, dest:location) -> [direction]{
        var finalDirections:[direction] = []
        
        //set up initial paths
        let startPath = allPaths.getPathByName(name:start.adjacentPath!)
        startPath.intersections.forEach{ inter in
            var directionPath:[direction] = []
            let interDirection = direction(p:startPath.name!, np:inter.0, dis:calcDistance(inter: inter, d:(start.lat!, start.lng!)), dir:chooseDirection(inter: inter, d:(start.lat!, start.lng!)), m:"")
            directionPath.append(interDirection)
            possibleRoutes.append((interDirection.distance!, directionPath))
        }
        
        //repeatedly expand until the shortest path reaches the goal
        var pathToExpand = nextInQueue()
        while pathToExpand.1.last?.nextPath != dest.name{
            let lastPath = allPaths.getPathByName(name:(pathToExpand.1.last?.path)!)
            let nextPath = allPaths.getPathByName(name:(pathToExpand.1.last?.nextPath)!)
            let lastInter = lastPath.getInterWith(name: nextPath.name!)
            if(dest.adjacentPath != nextPath.name){
                nextPath.intersections.forEach{ inter in
                    if inter.0 != pathToExpand.1.last?.path{
                    
                        var newDirections:[direction] = []
                        newDirections.append(contentsOf:pathToExpand.1)
                        
                        let newDirection = direction(p: nextPath.name!, np: inter.0, dis: calcDistance(inter: inter, d:(lastInter.0,lastInter.1)), dir: chooseDirection(inter: inter, d: (lastInter.0, lastInter.1)), m: "")
                        
                        newDirections.append(newDirection)
                        let newPartialRoute = (pathToExpand.0 + newDirection.distance!, newDirections)
                        possibleRoutes.append(newPartialRoute)
                    }
                }
            }
            else{
                var newDirections:[direction] = []
                newDirections.append(contentsOf:pathToExpand.1)
                
                let newDirection = direction(p: nextPath.name!, np: dest.name!, dis:calcFinalDistance(p1: lastInter, p2:(dest.lat!,dest.lng!)), dir: chooseFinalDirection(p1:lastInter, p2:(dest.lat!,dest.lng!), orient: nextPath.orientation!), m: "")
                
                newDirections.append(newDirection)
                let newPartialRoute = (pathToExpand.0 + newDirection.distance!, newDirections)
                possibleRoutes.append(newPartialRoute)            }
            
            pathToExpand = nextInQueue()
        }
        
        //add final direction
        let finalDirection = direction(p:dest.adjacentPath!, np:dest.name!, dis:0 ,dir:0, m:"Final")
        finalDirections = pathToExpand.1
        finalDirections.append(finalDirection)
        
        return finalDirections
    }
    
}