//
//  PrevRoute+CoreDataProperties.swift
//  MapASU
//
//  Created by Ian Bradley on 11/21/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//
//

import Foundation
import CoreData


extension PrevRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PrevRoute> {
        return NSFetchRequest<PrevRoute>(entityName: "PrevRoute")
    }

    @NSManaged public var start: String?
    @NSManaged public var dest: String?

}
