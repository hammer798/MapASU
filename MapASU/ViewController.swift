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
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destLabel: UILabel!
    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var editStartButton: UIButton!
    @IBOutlet weak var editDestButton: UIButton!
    @IBOutlet weak var walkOnlyToggle: UISegmentedControl!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var closePanelButton: UIButton!
    @IBOutlet weak var openPanelButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var initialMessage: UILabel!
    
    @IBOutlet weak var loadingImage: UIImageView!
    @IBOutlet weak var viewTopConstraint: NSLayoutConstraint!
    
    var classesArray: [course] = []
    var locationsArray: [location] = []
    var locationManager = CLLocationManager()
    var mode = 0
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var prevRoutes: [PreviousRoute] = []
    
    var allLocations = locations()
    var finalDirs = directions()
    var search = searchAPI()
    
    var loadingImages: [UIImage] = []
    
    var startString: String = ""
    var destString: String = ""
    
    var locServicesEnabled = true
    
    var startAnno = MKPointAnnotation()
    var destAnno = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        dataTable.dataSource = self
        dataTable.delegate = self
        locationManager.delegate = self
        theMap.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        getPrevRoutes()
        setUpLoadingImage()
        initializeMap()
        
    }
    
    func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.startUpdatingLocation()
            theMap.showsUserLocation = true
        }
        else{
            locServicesEnabled = false
            locationButton.isHidden = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if mode == 2 || mode == 4{
            return 0
        }
        else if classesArray.count > 0 && locationsArray.count > 0{
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == 0 {
            return prevRoutes.count
        }
        else if mode == 2 || mode == 4{
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
        else if mode == 0 && prevRoutes.count > 0{
            return "Previous Routes"
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
        
        cell.label1.isHidden = false
        cell.label2.isHidden = false
        cell.label3.isHidden = false
        cell.label4.isHidden = true
        cell.label5.isHidden = true
        if mode != 5 && mode != 0{
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
                cell.label3.text = "\(nextCourseData?.dayTime ?? "") \(nextCourseData?.place ?? "")"
                cell.label3.isHidden = false
            }
            else if nextLocData != nil{
                cell.label1.text = nextLocData?.name
                cell.label2.text = nextLocData?.abb
                cell.label3.text = ""
                cell.label3.isHidden = true
            }
        }
        else if mode == 0{
            //previous routes
            let prevRoute = prevRoutes[indexPath.row]
            cell.label4.text = "Start: \(prevRoute.start ?? "")"
            cell.label5.text = "Destination: \(prevRoute.dest ?? "")"
            cell.label1.isHidden = true
            cell.label2.isHidden = true
            cell.label3.isHidden = true
            cell.label4.isHidden = false
            cell.label5.isHidden = false
        }
        else{
            //directions cell
            let directionData = finalDirs.route[indexPath.row]
            cell.label1.text = directionData.message
            if directionData.distance != 0{
                cell.label2.text = "\(directionData.distance ?? 100) feet"
                cell.label2.isHidden = false
            }
            else{
                cell.label2.text = ""
                cell.label2.isHidden = true
            }
            cell.label3.text = ""
            cell.label3.isHidden = true
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mode != 5 && mode != 0{
            var displayString = ""
            var outputString = ""
            if indexPath.section == 0 && classesArray.count > 0{
                displayString = classesArray[indexPath.row].courseName
                outputString = classesArray[indexPath.row].place
                classesArray = []
            }
            else{
                outputString = locationsArray[indexPath.row].name ?? ""
                displayString = outputString
                
                locationsArray = []
            }
            
            if mode < 2{
                let startLoc = allLocations.matchStringToLocation(name: outputString)
                self.startAnno.coordinate = CLLocationCoordinate2D(latitude: startLoc.lat!, longitude: startLoc.lng!)
                self.startAnno.title = startLoc.name
                self.startAnno.subtitle = "Start"
                self.theMap.addAnnotation(self.startAnno)
                
                self.startString = outputString
                self.startField.text = displayString
                self.startField.isEnabled = false
                self.startField.alpha = 0.3
                self.editStartButton.isHidden = false
                self.locationButton.isHidden = true
                if destString == ""{
                    self.destField.isEnabled = true
                    self.destField.alpha = 1.0
                    self.editStartButton.isHidden = false
                    mode = 2
                }
                else{
                    self.routeButton.isHidden = false
                    self.editDestButton.isHidden = false
                    self.walkOnlyToggle.isHidden = false
                    mode = 4
                }
            }
            else{
                let endLoc = allLocations.matchStringToLocation(name: outputString)
                self.destAnno.coordinate = CLLocationCoordinate2D(latitude: endLoc.lat!, longitude: endLoc.lng!)
                self.destAnno.title = endLoc.name
                self.destAnno.subtitle = "Start"
                self.theMap.addAnnotation(self.destAnno)
                
                self.destString = outputString
                self.destField.text = displayString
                self.destField.isEnabled = false
                self.destField.alpha = 0.3
                self.searchButton.isHidden = true
                self.routeButton.isHidden = false
                self.editDestButton.isHidden = false
                self.walkOnlyToggle.isHidden = false
                mode = 4
            }
            DispatchQueue.main.async{
                self.dataTable.reloadData()
            }
        }
        else if mode == 0 && prevRoutes.count > 0{
            if indexPath.row < prevRoutes.count{
                let startS = prevRoutes[indexPath.row].start
                let destS = prevRoutes[indexPath.row].dest
                
                self.startField.text = startS
                self.startField.isEnabled = false
                self.startField.alpha = 0.3
                self.startString = startS!
                self.destField.text = destS
                self.destField.isEnabled = false
                self.destField.alpha = 0.3
                self.destString = destS!
                self.editStartButton.isHidden = false
                self.editDestButton.isHidden = false
                self.searchButton.isHidden = true
                self.routeButton.isHidden = false
                self.initialMessage.text = "Return to your route!"
                self.openPanelButton.setTitle("Open", for: .normal)
                self.openPanelButton.titleLabel?.textAlignment = .center
                
                let startLoc = allLocations.matchStringToLocation(name: startS!)
                self.startAnno.coordinate = CLLocationCoordinate2D(latitude: startLoc.lat!, longitude: startLoc.lng!)
                self.startAnno.title = startLoc.name
                self.startAnno.subtitle = "Start"
                self.theMap.addAnnotation(self.startAnno)
                
                let endLoc = allLocations.matchStringToLocation(name: destS!)
                self.destAnno.coordinate = CLLocationCoordinate2D(latitude: endLoc.lat!, longitude: endLoc.lng!)
                self.destAnno.title = endLoc.name
                self.destAnno.subtitle = "Start"
                self.theMap.addAnnotation(self.destAnno)
                
                self.getRouteHelper(start: startS!, dest: destS!)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        if let polyline = overlay as? MKPolyline{
            let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = .blue
            testlineRenderer.lineWidth = 2.0
            return testlineRenderer
        }
        fatalError("something wrong")
    }
    
    @IBAction func openSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 170
        dividerLine.isHidden = false
        dataTable.isHidden = false
        closePanelButton.isHidden = false
        openPanelButton.isHidden = true
        initialMessage.isHidden = true
        startField.isHidden = false
        startLabel.isHidden = false
        destField.isHidden = false
        destLabel.isHidden = false
        if mode < 2 && locServicesEnabled{
            locationButton.isHidden = false
        }
        if mode > 1{
            editStartButton.isHidden = false
        }
        if mode > 3{
            editDestButton.isHidden = false
        }
        
        if mode < 4{
            searchButton.isHidden = false
        }
        else{
            routeButton.isHidden = false
            walkOnlyToggle.isHidden = false
        }
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    
    }
    
    @IBAction func closeSearchMenu(_ sender: Any) {
        viewTopConstraint.constant = 706
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
        walkOnlyToggle.isHidden = true
        editStartButton.isHidden = true
        editDestButton.isHidden = true
        locationButton.isHidden = true
        UIView.animate(withDuration: 0.3, delay: 0.0, options:
            .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func searchForStuff(_ sender: Any) {
        self.loadingImage.isHidden = false
        self.initialMessage.text = "Return to your route!"
        self.openPanelButton.setTitle("Open", for: .normal)
        self.openPanelButton.titleLabel?.textAlignment = .center
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
                self.loadingImage.isHidden = true
            }
        }
        
    }
    
    @IBAction func editStart(_ sender: Any) {
        self.startString = ""
        self.mode = 0
        self.editStartButton.isHidden = true
        self.editDestButton.isHidden = true
        self.startField.isEnabled = true
        self.startField.alpha = 1.0
        self.destField.isEnabled = false
        self.destField.alpha = 0.3
        self.routeButton.isHidden = true
        self.searchButton.isHidden = false
        self.walkOnlyToggle.isHidden = true
        if locServicesEnabled{
            self.locationButton.isHidden = false
        }
        
        DispatchQueue.main.async{
            self.dataTable.reloadData()
        }
    }
    
    @IBAction func editDest(_ sender: Any) {
        self.destString = ""
        self.mode = 2
        self.editDestButton.isHidden = true
        self.startField.isEnabled = false
        self.startField.alpha = 0.3
        self.destField.isEnabled = true
        self.destField.alpha = 1.0
        self.routeButton.isHidden = true
        self.searchButton.isHidden = false
        self.walkOnlyToggle.isHidden = true
        
        DispatchQueue.main.async{
            self.dataTable.reloadData()
        }
    }
    
    @IBAction func chooseCurrentLoc(_ sender: Any) {
        self.startString = "Current Location"
        let userCoords = (self.theMap.userLocation.coordinate.latitude, self.theMap.userLocation.coordinate.longitude)
        let startLoc = allLocations.getNearestLoc(userCoords: userCoords)
        self.startAnno.coordinate = CLLocationCoordinate2D(latitude: startLoc.lat!, longitude: startLoc.lng!)
        self.startAnno.title = startLoc.name
        self.startAnno.subtitle = "Start"
        self.theMap.addAnnotation(self.startAnno)
        
        self.startField.text = self.startString
        self.startField.isEnabled = false
        self.locationButton.isHidden = true
        self.startField.alpha = 0.3
        self.editStartButton.isHidden = false
        if destString == ""{
            self.destField.isEnabled = true
            self.destField.alpha = 1.0
            self.editStartButton.isHidden = false
            mode = 2
        }
        else{
            self.routeButton.isHidden = false
            self.editDestButton.isHidden = false
            self.walkOnlyToggle.isHidden = false
            mode = 4
        }
        
        DispatchQueue.main.async{
            self.dataTable.reloadData()
        }
    }
    
    @IBAction func getRoute(_ sender: Any) {
        self.getRouteHelper(start: self.startString, dest: self.destString)
    }
    
    func getRouteHelper(start:String, dest:String){
        self.loadingImage.isHidden = false
        
        var coords:(Double?, Double?) = (91.0, 181.0) //invalid lat and lng
        if start.lowercased() == "current location"{
            let userLoc = self.theMap.userLocation.location
            coords = (userLoc?.coordinate.latitude, userLoc?.coordinate.longitude)
        }
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async{
            self.finalDirs.generateRoute(start: start, dest: dest, walkOnly: self.walkOnlyToggle.selectedSegmentIndex, userCoords: coords, group:group)
        }
        
        group.notify(queue: .main){
            self.mode = 5
            
            DispatchQueue.main.async{
                self.dataTable.reloadData()
                self.loadingImage.isHidden = true
                for overlay in self.theMap.overlays{
                    self.theMap.removeOverlay(overlay)
                }
                let routeLine = MKPolyline(coordinates: self.finalDirs.routeCoords, count: self.finalDirs.routeCoords.count)
                self.theMap.addOverlay(routeLine)
                self.saveRoute(start: self.startString, dest: self.destString)
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
    
    func setUpLoadingImage(){
        let loading1 = UIImage(named: "loading-1")!
        let loading2 = UIImage(named:"loading-2")!
        let loading3 = UIImage(named:"loading-3")!
        let loading4 = UIImage(named:"loading-4")!
        loadingImages.append(loading1)
        loadingImages.append(loading2)
        loadingImages.append(loading3)
        loadingImages.append(loading4)
        
        loadingImage.image = UIImage.animatedImage(with: loadingImages, duration: 1.0)
    }
    
    func getPrevRoutes(){
        let routeFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PreviousRoute")
        routeFetch.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    
        do {
            let fetchedRoutes = try managedObjectContext.fetch(routeFetch) as! [PreviousRoute]
            if fetchedRoutes.count > 0{
                self.prevRoutes.append(contentsOf: fetchedRoutes)
            }

        } catch {
            fatalError("Failed to fetch profile: \(error)")
        }
    }
    
    func saveRoute(start: String, dest: String){
        var existsAlready = false
        for prevRoute in prevRoutes{
            if prevRoute.start == start && prevRoute.dest == dest {
                existsAlready = true
                
                prevRoute.setValue(Date(), forKey: "timestamp")
                
                do{
                    try managedObjectContext.save()
                } catch let error as NSError{
                    print("could not save - \(error), \(error.userInfo)")
                }
                return
            }
        }
        
        if !existsAlready && start != "" && dest != ""{
            let entity = NSEntityDescription.entity(forEntityName: "PreviousRoute", in: managedObjectContext)!
            
            let route = NSManagedObject(entity: entity, insertInto: managedObjectContext)
            route.setValue(start, forKeyPath: "start")
            route.setValue(dest, forKeyPath: "dest")
            route.setValue(Date(), forKeyPath: "timestamp")
            
            // saving max of 5
            if prevRoutes.count == 5{
                managedObjectContext.delete(prevRoutes[4])
                prevRoutes.remove(at: 4)
            }
            
            do{
                try managedObjectContext.save()
                self.prevRoutes.insert(route as! PreviousRoute, at: 0)
            } catch let error as NSError {
                print("could not save - \(error), \(error.userInfo)")
            }
        }
    }
    
}

