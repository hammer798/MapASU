//
//  searchAPI.swift
//  MapASU
//
//  Created by Ian Bradley on 11/19/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//

import Foundation
import SwiftSoup

class searchAPI{

    var classesArray: [course] = []
    var locationsArray: [location] = []
    var returnedClasses: Bool = false

    init(){
        
    }
    
    func searchForThings(searchString:String){
        self.doClassSearch(searchString: searchString)
        self.doLocationSearch(searchString: searchString)
    }
    
    func doClassSearch(searchString:String){
        let classInfo = searchString.split(separator: " ")
        
        guard let url = URL(string: "https://webapp4.asu.edu/catalog/myclasslistresults?t=2207&s=" + classInfo[0] + "&n=" + classInfo[1] + "&hon=F&prod=F&c=TEMPE&e=all&page=1")  else { print("uh oh")
                           return }
                let task = URLSession.shared.dataTask(with:url) { data, response, error in
                    if let error = error{
                        print("error", error)
                    }
                    guard let httpResponse = response as? HTTPURLResponse,
                        (200...299).contains(httpResponse.statusCode) else{
                            print("failed")
                            return
                    }
                    if let data = data,
                        let string = String(data: data, encoding: .utf8) {
                        var names: [String] = []
                        var names2: [String] = []
                        var professors: [String] = []
                        var days: [String] = []
                        var times: [String] = []
                        var locations: [String] = []
                        do{
                            let doc = try SwiftSoup.parse(string)
                            let table = try doc.select("td")
                           
                            for tableElements in table {
                                if tableElements.hasClass("subjectNumberColumnValue"){
                                    let crn = try tableElements.text()
                                    names.append(crn)
                                }
                                else if tableElements.hasClass("titleColumnValue"){
                                    let className = try tableElements.text()
                                    if className.lowercased() == "recitation"{
                                        names2.append(" - Recitation")
                                    }
                                    else if className.lowercased() == "laboratory"{
                                        names2.append(" - Laboratory")
                                    }
                                    else{names2.append("")}
                                }
                                else if tableElements.hasClass("instructorListColumnValue") {
                                    let prof = try tableElements.text()
                                    professors.append(prof)
                                }
                                else if tableElements.hasClass("dayListColumnValue"){
                                    let day = try tableElements.text()
                                    days.append(day)
                                }
                                else if tableElements.hasClass("startTimeDateColumnValue") {
                                    let time = try tableElements.text()
                                    times.append(time)
                                }
                                else if tableElements.hasClass("locationBuildingColumnValue") {
                                    let place = try tableElements.text()
                                    locations.append(place)
                                }
                            }
                            for i in (0...professors.count-1){
                                let newCourse = course(cn: names[i] + names2[i], pro: professors[i], dt: days[i]  + " " + times[i], pl: locations[i])
                                self.classesArray.append(newCourse)
                            }
                            print(self.classesArray)
                            self.returnedClasses = true
                        }
                        catch let parserError{
                            print(parserError.localizedDescription)
                        }
                       
                    } else {print("what")}
                   
                }
                task.resume()
    }

    func doLocationSearch(searchString:String){
        let allLocations = locations()
        
        
        for loc in allLocations.allLocations{
            if loc.name!.lowercased().contains(searchString.lowercased()){
                locationsArray.append(loc)
            }
            else if searchString.lowercased().contains(loc.name!.lowercased()){
                locationsArray.append(loc)
            }
            else{
                let abbs = loc.abb!.split(separator: "/")
                for abb in abbs{
                    if(searchString.uppercased().contains(abb)){
                        locationsArray.append(loc)
                    }
                    else if abb.contains(searchString.uppercased()){
                        locationsArray.append(loc)
                    }
                }
            }
        }
    }
}
