//
//  Measurements.swift
//  gcmapp
//
//  Created by Jon Vellacott on 04/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class Measurements: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var perm_link: String
    @NSManaged var section: String
    @NSManaged var column: String
    @NSManaged var ministry_id: String
    @NSManaged var id_total: String
    @NSManaged var id_local: String
    @NSManaged var id_person: String
    @NSManaged var measurementValue: NSSet

}
