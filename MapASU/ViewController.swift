//
//  ViewController.swift
//  MapASU
//
//  Created by Ian Bradley on 8/14/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SwiftSoup

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var walkOnlyToggle: UISegmentedControl!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var closePanelButton: UIButton!
    @IBOutlet weak var openPanelButton: UIButton!
    @IBOutlet weak var initialMessage: UILabel!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    var classesArray: [course] = []
    var locationsArray: [location] = []
    var locationManager = CLLocationManager()
    var mode = 0
    
    var finalDirs = directions()
    var search = searchAPI()
    
    var startString: String = ""
    var destString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataTable.dataSource = self
        dataTable.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        initializeMap()
        
    }
    
    func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            theMap.showsUserLocation = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if mode == 0 || mode == 2 || mode == 4{
            return 0
        }
        else if classesArray.count > 0 && locationsArray.count > 0{
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == 0 || mode == 2 || mode == 4{
            //blank while we get input
            return 0
        }
        else if mode == 1 || mode == 3 {
            //search results
            if section == 0 && self.classesArray.count > 0{
                return self.classesArray.count
            }
            else {
                return self.locationsArray.count
            }
        }
        else if mode == 5{
            //show directions
            return self.finalDirs.route.count
        }
        else{
            //default
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        if mode == 5{
            return "Directions"
        }
        else if classesArray.count > 0 && locationsArray.count > 0{
            if section == 0{
                return "Courses"
            }
            else{
                return "Buildings"
            }
        }
        else if classesArray.count > 0{
            return "Courses"
        }
        else if locationsArray.count > 0{
            return "Buildings"
        }
        else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoDisplayTableCell", for: indexPath) as? InfoDisplayTableViewCell  else {
            fatalError("The dequeued cell is not an instance of InfoDisplayTableViewCell.")
        }
                
        var nextCourseData: course?
        var nextLocData: location?
        
        if mode != 5{
            if classesArray.count > 0 && locationsArray.count > 0{
                if indexPath.section == 0{
                    nextCourseData = classesArray[indexPath.row]
                }
                else{
                    nextLocData = locationsArray[indexPath.row]
                }
            }
            else if classesArray.count > 0{
                nextCourseData = classesArray[indexPath.row]
            }
            else{
                nextLocData = locationsArray[indexPath.row]
            }
            
            if nextCourseData != nil{
                cell.label1.text = nextCourseData?.courseName
                cell.label2.text = nextCourseData?.professor
                cell.label3.text = nextCourseData!.dayTime + " " + nextCourseData!.place
            }
            else if nextLocData != nil{
                cell.label1.text = nextLocData?.name
                cell.label2.text = nextLocData?.abb
                cell.label3.text = ""
                cell.label3.isHidden = true
            }
        }
        else{
            //directions cell
            let directionData = finalDirs.route[indexPath.row]
            cell.label1.text = directionData.message
            cell.label2.text = "\(directionData.distance ?? 100) feet"
            cell.label3.text = ""
            cell.label3.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode != 5{
            var outputString = ""
            if indexPath.section == 0 && classesArray.count > 0{
                outputString = classesArray[indexPath.row].courseName
                classesArray = []
            }
            else{
                outputString = locationsArray[indexPath.row].name ?? ""
                locationsArray = []
            }
            
            if mode < 2{
                self.startString = outputString
                self.startField.text = outputString
                self.startField.isEnabled = false
                self.destField.isEnabled = true
                //show edit button for start
                mode = 2
            }
            else{
                self.destString = outputString
                self.destField.text = outputString
                self.destField.isEnabled = false
                self.searchButton.isHidden = true
                self.routeButton.isHidden = false
                
                //show find route button and edit button for dest
                mode = 4
            }
            DispatchQueue.main.async{
                self.dataTable.reloadData()
            }
        }
    }
    
    @IBAction func openSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 100
        dividerLine.isHidden = false
        dataTable.isHidden = false
        closePanelButton.isHidden = false
        openPanelButton.isHidden = true
        initialMessage.isHidden = true
        startField.isHidden = false
        startLabel.isHidden = false
        destField.isHidden = false
        destLabel.isHidden = false
        searchButton.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    
    }
    
    @IBAction func closeSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 656
        dividerLine.isHidden = true
        dataTable.isHidden = true
        closePanelButton.isHidden = true
        openPanelButton.isHidden = false
        initialMessage.isHidden = false
        startField.isHidden = true
        startLabel.isHidden = true
        destField.isHidden = true
        destLabel.isHidden = true
        searchButton.isHidden = true
        routeButton.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options:
            .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func searchForStuff(_ sender: Any) {
        self.initialMessage.text = "Return to Route"
        self.openPanelButton.titleLabel?.text = "Open"
        var searchString = ""
        if mode == 0 || mode == 1{
            guard let start = startField.text else{return}
            searchString = start
        }
        else{
            guard let dest = destField.text else{return}
            searchString = dest
        }
        
        let theGroup = DispatchGroup()
        theGroup.enter()
        DispatchQueue.main.async{
            self.search.searchForThings(searchString: searchString, group: theGroup)
        }
        
        theGroup.notify(queue: .main){
            self.classesArray = self.search.classesArray
            self.locationsArray = self.search.locationsArray
            
            //show data
            if(self.mode != 1 && self.mode != 3){
                self.mode+=1
            }
            //reset table
            DispatchQueue.main.async{
                self.dataTable.reloadData()
            }
        }
        
    }
    
    @IBAction func getRoute(_ sender: Any) {
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async{
            self.finalDirs.generateRoute(start: self.startString, dest: self.destString, group:group)
        }
        
        group.notify(queue: .main){
            self.mode = 5
            
            DispatchQueue.main.async{
                self.dataTable.reloadData()
            }
        }
    }
    
    func initializeMap(){
        let lon : CLLocationDegrees = -111.93259921
        let lat : CLLocationDegrees = 33.41895898
        let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.016)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinates, span: span)
        self.theMap.setRegion(region, animated: true)
        self.theMap.showsUserLocation = true
    }
    
}

