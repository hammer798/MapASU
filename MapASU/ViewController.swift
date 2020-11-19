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
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var walkOnlyToggle: UISegmentedControl!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var closePanelButton: UIButton!
    
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    var classesArray: [(String, String, String)] = []
    var locationManager = CLLocationManager()
    var mode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == 0 {
            return 0
        }
        else if mode == 1 {
            return classesArray.count
        }
        else{
            //do stuff
            //do i need this?
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InfoDisplayTableCell", for: indexPath) as? InfoDisplayTableViewCell  else {
            fatalError("The dequeued cell is not an instance of InfoDisplayTableViewCell.")
        }
        let nextData = classesArray[indexPath.row]
        cell.label1.text = nextData.0
        cell.label2.text = nextData.1
        cell.label3.text = nextData.2
        
        return cell
    }
    @IBAction func openSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 100
        dividerLine.isHidden = false
        dataTable.isHidden = false
        closePanelButton.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    
    }
    
    @IBAction func closeSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 656
        dividerLine.isHidden = true
        dataTable.isHidden = true
        closePanelButton.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options:
            .curveEaseIn, animations: {
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
        task.resume()
        
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

