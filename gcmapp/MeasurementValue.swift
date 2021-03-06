//
//  MeasurementValue.swift
//  gcmapp
//
//  Created by Jon Vellacott on 18/03/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(MeasurementValue)
class MeasurementValue: NSManagedObject {

    @NSManaged var changed_local: NSNumber
    @NSManaged var local: NSNumber
    @NSManaged var mcc: String
    @NSManaged var me: NSNumber
    @NSManaged var period: String
    @NSManaged var subtotal: NSNumber
    @NSManaged var total: NSNumber
    @NSManaged var changed_me: NSNumber
    @NSManaged var localSources: NSSet
    @NSManaged var measurement: Measurements
    @NSManaged var meSources: NSSet
    @NSManaged var selfAssigned: NSSet
    @NSManaged var subMinValues: NSSet
    @NSManaged var teamValues: NSSet

}
