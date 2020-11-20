//
//  class.swift
//  MapASU
//
//  Created by Ian Bradley on 11/20/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//

import Foundation

class course{
    
    var courseName: String
    var professor: String
    var dayTime: String
    var place: String
    
    init(cn: String, pro:String, dt:String, pl:String){
        courseName = cn
        professor = pro
        dayTime = dt
        place = pl
    }
}
