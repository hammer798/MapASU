//
//  locations.swift
//  
//
//  Created by ibradle1 on 11/2/19.
//  Copyright © 2019 ibradle1. All rights reserved.
//

import Foundation
import CoreLocation

class locations {
    var allLocations:[location] = [location]()
    var names:[String] = ["Current Location", "College of Design", "Neeb Hall", "Stauffer Communication Arts", "Coor Hall", "Payne Hall", "Farmer Education Building", "Education Lecture Hall", "Music Building", "Center for Family Studies", "Matthews Hall", "Dixie Gammage Hall", "West Hall", "Wilson Hall", "Discovery Hall", "Hayden Library", "Matthews Center", "School of Human Evolution and Social Change", "Cowden Family Resources Building", "Durham Languages and Literature Building", "Social Sciences Building", "Business Administration", "Business Administration C Wing", "McCord Hall", "Life Sciences Center", "Piper Writer's House", "Murdock Lecture Hall", "Sun Devil Hall", "Sun Devil Fitness Complex", "Computing Commons", "Engineering Center", "Wexler Hall", "Bateman Physical Science Center", "San Pablo Classroom", "Goldwater Center for Science and Engineering", "Psychology North", "Urban Systems Engineering", "Schwada Classroom Office Building", "Bulldog Hall", "Armstrong Hall", "Ross-Blakely Hall", "Brickyard Engineering", "Hayden Hall", "Irish Hall", "McClintock Hall", "Villas at Vista Del Sol", "Vista Del Sol", "Barrett Residential Complex", "Adelphi Commons", "Sonora Center", "Hassayampa Residential Village", "Manzanita Hall", "Palo Verde", "Tooker House", "San Pablo Residence Hall", "Greek Leadership Village"]
    var coords: [(Double, Double)] = [(33.421444,-111.937065),(33.420315, -111.936897),(33.419876,   -111.936852),(33.419353,    -111.937294),(33.418877,    -111.937248),(33.418049,    -111.937241),(33.417904,    -111.937843),(33.418037,    -111.939018),(33.421021,    -111.936287),(33.420113,    -111.936119),(33.419098,    -111.93618),(33.419098,    -111.935814),(33.418518,    -111.935951),(33.41647,    -111.935524),(33.418938,    -111.935242),(33.41993,    -111.935471),(33.420574,    -111.935486),(33.421032,    -111.93557),(33.420921,    -111.934532),(33.419926,    -111.934479),(33.416618,    -111.934509),(33.41655,    -111.933838),(33.416828,    -111.933197),(33.419876,    -111.933144),(33.420532,    -111.933029),(33.418629,    -111.933144),(33.417805,    -111.933098),(33.415447,    -111.932426),(33.417831,    -111.932388),(33.419315,    -111.932205),(33.42057,    -111.932159),(33.420956,    -111.931396),(33.42244, -111.931335), (33.420784, -111.930466),(33.420631,    -111.929558),(33.421558,    -111.92952),(33.418987,    -111.930588),(33.417904,    -111.930786),(33.417835,    -111.929443),(33.417126,    -111.929642),(33.423401,    -111.939537),(33.415012,    -111.935753),(33.415668,    -111.935242),(33.419697,    -111.936089),(33.414398,    -111.931725),(33.413101,    -111.929153), (33.415279,    -111.927498),(33.414467,    -111.927773),(33.411968,    -111.927521),(33.415474,    -111.930023),(33.422466,    -111.930061),(33.422478,    -111.933586),(33.423271,    -111.933372),(33.422859,    -111.931297),(33.418934, -111.925247)]
    
    var adjacentPaths: [String] = ["Forest Mall", "Forest Mall", "Forest Mall", "Forest Mall", "Forest Mall", "Forest Mall", "Gammage Parkway", "Gammage Parkway", "Forest Mall", "Tyler Mall", "Forest Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Cady Mall", "Lemon Mall", "Palm Walk", "Tyler Mall", "Tyler Mall","Palm Walk", "Palm Walk", "Lemon Mall", "Palm Walk", "Palm Walk", "Tyler Mall", "Tyler Mall", "University Drive", "Tyler Mall", "Tyler Mall", "University Drive", "McAlister Mall", "Orange Mall", "McAlister Avenue", "McAlister Avenue", "Mill Avenue", "Apache Boulevard", "Cady Mall", "Forest Mall", "Apache Boulevard", "Apache Boulevard", "Lemon Mall", "Apache Boulevard", "Rural Road", "Lemon Mall", "University Drive", "Palm Walk", "Palm Walk", "University Drive", "Rural Road"]
     var abbreviations: [String] = ["None", "CD", "NEEB","STAUF", "COOR", "EDB", "ED", "EDC", "MUSIC", "CFS", "MHALL", "GHALL", "WHALL", "WILSN", "DISCVRY", "LIB", "MCENT", "SHESC", "COWDN", "LL", "SS", "BA", "BAC", "MCRD", "LS", "PWH", "MUR", "SDH", "SDFC", "CRTVC", "EC", "WXLR", "PSA/PSB/PSC/PSD/PSE/PSF/PSG/PSH", "PABLO", "GWC", "PSYN", "USE", "SCOB", "BDH", "ARM", "RBHL", "BYENG/BYAC", "HAYDN", "IRISH", "MCL", "VVDS", "VDS", "AGVHAL/CERHAL/CWHAL/HONHAL/JNHAL/RWHAL/SGHAL/WILOHAL", "ADE", "SCD", "ACACI/ACHAL/ARHAL/CHUPA/JOBA/MSHAL/MVHAL/VBHAL", "MANZH", "PV", "TKR", "PABLO", "GLV"]
    init(){
        //get current location
        let currLoc = location(latitude: -1, longitude: -1, locname: names[0], adjPath:"", abbreviation:abbreviations[0])
        allLocations.append(currLoc)
        //iterate through
        for index in 1..<names.count {
            let loc:location = location(latitude:coords[index-1].0, longitude:coords[index-1].1, locname:names[index], adjPath:adjacentPaths[index-1], abbreviation:abbreviations[index])
            allLocations.append(loc)
        }
    }
    
    func getLocationObject(item: Int) -> location {
        return allLocations[item]
    }
    
    func getLocationIndex(name:String)->Int{
        for i in 0...allLocations.count - 1{
            if allLocations[i].name == name {
                return i
            }
        }
        return -1
    }
    
    func matchStringToLocation(name:String)->location{
        for loc in allLocations{
            if loc.name == name{
                return loc
            }
            else if name.lowercased().contains("tempe"){
                let abbs = loc.abb!.split(separator: "/")
                let placeAbb = name.split(separator: "-").last
                
                for abb in abbs{
                    if placeAbb!.contains(abb){
                        return loc
                    }
                }
            }
        }
        return allLocations[1]
    }
    
    func getNearestLoc(userCoords: (Double?, Double?)) -> location{
        let userLoc = CLLocation(latitude:userCoords.0!, longitude:userCoords.1!)
        
        var nearest = -1.0
        var nearestLoc = allLocations[0]
        
        for loc in allLocations{
            let locLocation = CLLocation(latitude: loc.lat!, longitude: loc.lng!)
            if nearest == -1.0 || userLoc.distance(from: locLocation) < nearest{
                nearest = userLoc.distance(from:locLocation)
                nearestLoc = loc
            }
        }
        
        return nearestLoc
    }
    
    func getCount() -> Int {
        return names.count
    }
}
