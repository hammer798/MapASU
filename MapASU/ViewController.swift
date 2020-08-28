//
//  ViewController.swift
//  MapASU
//
//  Created by Ian Bradley on 8/14/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var theMap: MKMapView!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var destField: UITextField!
    @IBOutlet weak var walkOnlyToggle: UISegmentedControl!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

