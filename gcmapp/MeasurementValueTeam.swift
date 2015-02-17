//
//  MeasurementValueTeam.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementValueTeam: NSManagedObject {

    @NSManaged var assignment_id: String
    @NSManaged var first_name: String
    @NSManaged var last_name: String
    @NSManaged var team_role: String
    @NSManaged var total: NSNumber
    @NSManaged var changed: NSNumber
    @NSManaged var measurementValue: GMAapp.MeasurementValue

}
