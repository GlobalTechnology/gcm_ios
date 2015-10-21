//
//  MeasurementValueTeam.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(MeasurementValueTeam)
class MeasurementValueTeam: NSManagedObject {

    @NSManaged var assignment_id: String
    @NSManaged var changed: NSNumber
    @NSManaged var first_name: String
    @NSManaged var last_name: String
    @NSManaged var team_role: String
    @NSManaged var total: NSNumber
    @NSManaged var measurementValue: MeasurementValue

}
