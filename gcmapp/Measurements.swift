//
//  Measurements.swift
//  gcmapp
//
//  Created by Jon Vellacott on 03/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

class Measurements: NSManagedObject {

    @NSManaged var column: String
    @NSManaged var id: String
    @NSManaged var id_local: String
    @NSManaged var id_person: String
    @NSManaged var id_total: String
    @NSManaged var ministry_id: String
    @NSManaged var name: String
    @NSManaged var perm_link: String
    @NSManaged var section: String
    @NSManaged var sort_order: NSNumber
    @NSManaged var measurementValue: NSSet

}
