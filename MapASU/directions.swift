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
    var routeCoords:[CLLocationCoordinate2D] = []
    var startName: String?
    var destName: String?
    
    var possibleRoutes:[(Int,[direction])] = [(Int,[direction])]()
    
    init(){}
    
    func generateRoute(start:String, dest:String, walkOnly: Int, userCoords: (Double?, Double?), group: DispatchGroup){
        
        //get location values
        var stLoc = allLocations.allLocations[0]
        if start.lowercased() == "current location"{
            let currLoc = allLocations.getNearestLoc(userCoords: userCoords)
            stLoc = currLoc
        }
        else{
            stLoc = allLocations.matchStringToLocation(name: start)
        }
        let destLoc = allLocations.matchStringToLocation(name: dest)
        
        //reset arrays
        self.route = []
        self.possibleRoutes = []
        self.routeCoords = []
        
        self.route = dijkstra(start: stLoc, dest: destLoc, walkOnly: walkOnly)
        self.createCoordsArray(start:stLoc, dest:destLoc)
        
        group.leave()
    }
    
    func calcDistance(inter:(String, Double),d:(Double,Double)) -> Int{
        let des:CLLocation = CLLocation(latitude: d.0, longitude: d.1)
        var st:CLLocation?
        if abs(d.1 - inter.1) > abs(d.0 - inter.1){
            st = CLLocation(latitude: inter.1, longitude:d.1)
        }
        else{
            st = CLLocation(latitude: d.0, longitude:inter.1)
            
        }
        let st2 = CLLocation(latitude:(st?.coordinate.latitude)!, longitude: (st?.coordinate.longitude)!)
        let meters:Double = st2.distance(from: des)
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
                return 0
            }
            else{
                return 2
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
    
    func dijkstra(start:location, dest:location, walkOnly: Int) -> [direction]{
        var finalDirections:[direction] = []
        
        //set up initial paths
        let startPath = allPaths.getPathByName(name:start.adjacentPath!)
        startPath.intersections.forEach{ inter in
            var directionPath:[direction] = []
            let interDirection = direction(p:startPath.name!, np:inter.0, dis:calcDistance(inter: inter, d:(start.lat!, start.lng!)), dir:chooseDirection(inter: inter, d:(start.lat!, start.lng!)), m:"")
            var directDistance = interDirection.distance
            if walkOnly == 1{
                if startPath.walkOnly!{
                    directDistance = Int(round(Double(directDistance!) * 1.5))
                }
            }
            directionPath.append(interDirection)
            possibleRoutes.append((directDistance!, directionPath))
        }
        
        if startPath.name == dest.adjacentPath{
            var directionPath:[direction] = []
            let onlyDirection = direction(p:startPath.name!, np:dest.name!, dis:calcFinalDistance(p1: (start.lat!, start.lng!), p2: (dest.lat!, dest.lng!)), dir:chooseFinalDirection(p1:(start.lat!, start.lng!), p2: (dest.lat!, dest.lng!), orient: startPath.orientation!), m:"")
            var directDistance = onlyDirection.distance
            if walkOnly == 1{
                if startPath.walkOnly!{
                    directDistance = Int(round(Double(directDistance!) * 1.5))
                }
            }
            directionPath.append(onlyDirection)
            possibleRoutes.append((directDistance!, directionPath))
            
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
                        
                        var directDistance = newDirection.distance
                        if walkOnly == 1{
                            if nextPath.walkOnly!{
                                directDistance = Int(round(Double(directDistance!) * 1.5))
                            }
                        }
                        newDirections.append(newDirection)
                        let newPartialRoute = (pathToExpand.0 + directDistance!, newDirections)
                        possibleRoutes.append(newPartialRoute)
                    }
                }
            }
            else{
                var newDirections:[direction] = []
                newDirections.append(contentsOf:pathToExpand.1)
                
                let newDirection = direction(p: nextPath.name!, np: dest.name!, dis:calcFinalDistance(p1: lastInter, p2:(dest.lat!,dest.lng!)), dir: chooseFinalDirection(p1:lastInter, p2:(dest.lat!,dest.lng!), orient: nextPath.orientation!), m: "")
                var directDistance = newDirection.distance
                if walkOnly == 1{
                    if nextPath.walkOnly!{
                        directDistance = Int(round(Double(directDistance!) * 1.5))
                    }
                }
                newDirections.append(newDirection)
                let newPartialRoute = (pathToExpand.0 + directDistance!, newDirections)
                possibleRoutes.append(newPartialRoute)            }
            
            pathToExpand = nextInQueue()
        }
        
        //add final direction
        let finalDirection = direction(p:dest.adjacentPath!, np:dest.name!, dis:0 ,dir:0, m:"Final")
        finalDirections = pathToExpand.1
        finalDirections.append(finalDirection)
        
        return finalDirections
    }
    
    func createCoordsArray(start:location, dest:location){
        let startPath = allPaths.getPathByName(name: start.adjacentPath!)
        if startPath.orientation == 0{
            let startCoords = CLLocationCoordinate2D(latitude: start.lat!, longitude: startPath.long1!)
            self.routeCoords.append(startCoords)
        }
        else{
            let startCoords = CLLocationCoordinate2D(latitude:startPath.lat1!, longitude: start.lng!)
            self.routeCoords.append(startCoords)
        }
        for dir in self.route{
            if dir.nextPath == dest.name{
                let lastPath = allPaths.getPathByName(name: dest.adjacentPath!)
                if lastPath.orientation == 0{
                    let coords = CLLocationCoordinate2D(latitude: dest.lat!, longitude: lastPath.long1!)
                    self.routeCoords.append(coords)
                }
                else{
                    let startCoords = CLLocationCoordinate2D(latitude:lastPath.lat1!, longitude: dest.lng!)
                    self.routeCoords.append(startCoords)                }
                return
            }
            else{
                let thePath = allPaths.getPathByName(name: dir.nextPath!)
                let inter = thePath.getInterWith(name: dir.path!)
                let coords = CLLocationCoordinate2D(latitude: inter.0, longitude: inter.1)
                self.routeCoords.append(coords)
            }
        }
    }
    
}
