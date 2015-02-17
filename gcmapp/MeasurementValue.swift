//
//  MeasurementValue.swift
//  gcmapp
//
//  Created by Jon Vellacott on 05/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData

class MeasurementValue: NSManagedObject {

    @NSManaged var changed: NSNumber
    @NSManaged var local: NSNumber
    @NSManaged var mcc: String
    @NSManaged var me: NSNumber
    @NSManaged var period: String
    @NSManaged var total: NSNumber
    @NSManaged var localSources: NSSet
    @NSManaged var measurement: GMAapp.Measurements
    @NSManaged var selfAssigned: NSSet
    @NSManaged var subMinValues: NSSet
    @NSManaged var teamValues: NSSet
    @NSManaged var meSources: NSSet

}
