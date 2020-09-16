//
//  ViewController.swift
//  MapASU
//
//  Created by Ian Bradley on 8/14/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//

import UIKit
import MapKit
import SwiftSoup

class ViewController: UIViewController {

    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var walkOnlyToggle: UISegmentedControl!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    var classesArray: [(String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 100
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    
    }
    
    @IBAction func searchForStuff(_ sender: Any) {
        var classInfo: [String.SubSequence] = []
        guard let dest = destField.text else{return}
        if(dest.contains(" ")){
            classInfo = dest.split(separator: " ")
            getClassInfo(classInfo: classInfo)
        }
        else{
            return
        }
                
        
    }
    
    func getClassInfo(classInfo:[String.SubSequence]){
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
                var professors: [String] = []
                var times: [String] = []
                var locations: [String] = []
                do{
                    let doc = try SwiftSoup.parse(string)
                    let table = try doc.select("td")
                    
                    for tableElements in table {
                        if tableElements.hasClass("instructorListColumnValue") {
                            let prof = try tableElements.text()
                            professors.append(prof)
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
                        self.classesArray.append((professors[i], times[i], locations[i]))
                    }
                    print(self.classesArray)
                }
                catch let parserError{
                    print(parserError.localizedDescription)
                }
                
            } else {print("what")}
            
        }
        task.resume()    }
    
}

