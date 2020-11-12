//
//  direction.swift
//  
//
//  Created by ibradle1 on 11/23/19.
//  Copyright © 2019 ibradle1. All rights reserved.
//

import Foundation

class direction {
    
    var path:String?
    var distance:Int?
    var direction:Int? //0 is N, 1 is E, 2 is S, 3 is W
    var message:String?
    
    init(p:String, dis:Int, dir:Int, m:String){
        path = p
        distance = dis
        direction = dir
        if m == "Final" {
            message = "Arrive at your destination."
        }
        else if m == "Fail"{
            message = "You are too far away to route from your location."
        }
        else{
            switch(dir){
                case 0: message = "Go north on \(p)"
                case 1: message = "Go east on \(p)"
                case 2: message = "Go south on \(p)"
                default: message = "Go west on \(p)"
            }
        }
    }
    
}
