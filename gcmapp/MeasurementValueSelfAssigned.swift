//
//  MeasurementValueSelfAssigned.swift
//  gcmapp
//
//  Created by Jon Vellacott on 10/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementValueSelfAssigned: NSManagedObject {

    @NSManaged var first_name: String
    @NSManaged var last_name: String
    @NSManaged var total: NSNumber
    @NSManaged var assignment_id: String
    @NSManaged var measurementValue: MeasurementValue

}
