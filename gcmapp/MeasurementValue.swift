//
//  MeasurementValue.swift
//  gcmapp
//
//  Created by Jon Vellacott on 11/12/2014.
//  Copyright (c) 2014 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementValue: NSManagedObject {

    @NSManaged var local: NSNumber
    @NSManaged var mcc: String
    @NSManaged var me: NSNumber
    @NSManaged var period: String
    @NSManaged var total: NSNumber
    @NSManaged var changed: NSNumber
    @NSManaged var localSources: NSSet
    @NSManaged var measurement: gcmapp.Measurements
    @NSManaged var selfAssigned: NSSet
    @NSManaged var subMinValues: NSSet
    @NSManaged var teamValues: NSSet

}
