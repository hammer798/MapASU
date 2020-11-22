//
//  PreviousRoute+CoreDataProperties.swift
//  MapASU
//
//  Created by Ian Bradley on 11/22/20.
//  Copyright © 2020 Ian Bradley. All rights reserved.
//
//

import Foundation
import CoreData


extension PreviousRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PreviousRoute> {
        return NSFetchRequest<PreviousRoute>(entityName: "PreviousRoute")
    }

    @NSManaged public var start: String?
    @NSManaged public var dest: String?
    @NSManaged public var timestamp: Date?

}
