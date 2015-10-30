//
//  MeasurementMeSource.swift
//  gcmapp
//
//  Created by Jon Vellacott on 27/02/2015.
//  Copyright (c) 2015 Expidev. All rights reserved.
//

import Foundation
import CoreData
@objc(MeasurementMeSource)
class MeasurementMeSource: NSManagedObject {

    @NSManaged var changed: NSNumber
    @NSManaged var name: String
    @NSManaged var value: NSNumber
    @NSManaged var measurementValue: MeasurementValue

}
